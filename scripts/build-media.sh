#!/usr/bin/env bash
# Dev-only media builder for the bundled collection. Not used at runtime.
#
# Reads the catalog from engine/Collection.js, resolves each Wikimedia Commons file page
# through the Commons API, refuses anything that is not public domain or CC0, caches the
# originals outside the repository, encodes the shipped assets, synthesizes the original
# sound effects, and rewrites assets/media.json with provenance and checksums.
#
# Requires: node, python3, magick (ImageMagick 7), ffmpeg with libopus, network access.
# Existing encoded assets are kept; delete one to re-encode it. Licenses are re-verified
# on every run.
set -euo pipefail
cd "$(dirname "$0")/.."

export JZA_CACHE="${JZA_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/jezz-atelier-media}"
mkdir -p "$JZA_CACHE" assets/artworks assets/music assets/sfx

export JZA_CATALOG
JZA_CATALOG="$(node -e '
  const fs = require("fs")
  const source = fs.readFileSync("engine/Collection.js", "utf8").replace(/^\.pragma library/m, "")
  const module = { exports: {} }
  new Function("module", source)(module)
  const { artworks, tracks, sfx } = module.exports
  process.stdout.write(JSON.stringify({ artworks, tracks, sfx }))
')"

python3 - <<'PYTHON'
import hashlib
import json
import math
import os
import pathlib
import shutil
import struct
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
import wave

CATALOG = json.loads(os.environ["JZA_CATALOG"])
CACHE = pathlib.Path(os.environ["JZA_CACHE"])
USER_AGENT = "jezz-atelier-build/0.1 (github.com/julianbruno)"
ALLOWED_LICENSE_PREFIXES = ("public domain", "pd-", "pd ", "cc0", "cc-zero")

# Original tone sequences (Hz) for the project's own sound effects.
SFX_NOTES = {
    "build": [440, 660],
    "capture": [523, 659, 784],
    "life-lost": [220, 164],
    "level-clear": [523, 659, 784, 1047],
    "game-over": [330, 262, 196],
}
SAMPLE_RATE = 44100
NOTE_STAGGER = 0.075
NOTE_LENGTH = 0.22
PEAK = 8192  # about -12 dBFS


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def open_url(url, timeout):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    for attempt in range(7):
        try:
            return urllib.request.urlopen(request, timeout=timeout)
        except urllib.error.HTTPError as error:
            if error.code not in (429, 503) or attempt == 6:
                raise
            delay = max(int(error.headers.get("Retry-After", "0") or 0), 2 ** (attempt + 2))
            print(f"Commons throttled; waiting {delay} s", flush=True)
            time.sleep(delay)


def commons_file_info(source_url):
    title = urllib.parse.unquote(source_url.split("/wiki/", 1)[1]).replace("_", " ")
    query = urllib.parse.urlencode({
        "action": "query",
        "format": "json",
        "prop": "imageinfo",
        "iiprop": "url|extmetadata|size",
        "titles": title,
    })
    with open_url("https://commons.wikimedia.org/w/api.php?" + query, timeout=90) as response:
        pages = json.load(response)["query"]["pages"]
    info = next(iter(pages.values())).get("imageinfo", [None])[0]
    if not info:
        raise RuntimeError("Commons original not found: " + source_url)
    return info


def cached_original(entry_id, info):
    url = info["url"].split("?", 1)[0]
    cached = CACHE / (entry_id + pathlib.PurePosixPath(urllib.parse.urlparse(url).path).suffix)
    if cached.exists() and cached.stat().st_size == info["size"]:
        return url, cached

    staging = cached.with_name(cached.name + ".part")
    with open_url(url, timeout=180) as response, staging.open("wb") as output:
        shutil.copyfileobj(response, output)
    if staging.stat().st_size != info["size"]:
        raise RuntimeError("Original size mismatch: " + entry_id)
    staging.replace(cached)
    return url, cached


def encode_artwork(original, output):
    subprocess.run([
        "magick", str(original), "-auto-orient", "-resize", "1600x1600>", "-colorspace", "sRGB",
        "-strip", "-interlace", "Plane", "-quality", "82", str(output),
    ], check=True)


def encode_track(original, output, title):
    subprocess.run([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(original), "-vn",
        "-c:a", "libopus", "-b:a", "64k", "-ac", "2", "-map_metadata", "-1",
        "-metadata", "title=" + title, str(output),
    ], check=True)


def sine(frequency):
    raw = subprocess.check_output([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "lavfi",
        "-i", f"sine=frequency={frequency}:sample_rate={SAMPLE_RATE}:duration={NOTE_LENGTH}",
        "-f", "s16le", "-acodec", "pcm_s16le", "-",
    ])
    return [value[0] / 32768 for value in struct.iter_unpack("<h", raw)]


def envelope(age):
    # 12 ms attack, exponential decay, forced to silence at the end of the note.
    return min(1, age / 0.012) * math.exp(-age / 0.055) * (1 - age / NOTE_LENGTH)


def synthesize_sfx(notes, output):
    oscillators = [sine(frequency) for frequency in notes]
    duration = (len(notes) - 1) * NOTE_STAGGER + NOTE_LENGTH
    samples = []
    for n in range(math.ceil(duration * SAMPLE_RATE)):
        amplitude = 0.0
        for i, oscillator in enumerate(oscillators):
            age = n / SAMPLE_RATE - i * NOTE_STAGGER
            index = round(age * SAMPLE_RATE)
            if 0 <= index < len(oscillator):
                amplitude += oscillator[index] * envelope(age)
        samples.append(amplitude)

    peak = max(abs(sample) for sample in samples)
    with wave.open(str(output), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(b"".join(struct.pack("<h", round(sample / peak * PEAK)) for sample in samples))


def record(entry, kind, output, **extra):
    fields = {key: entry.get(key) for key in ("id", "title", "creator", "date", "sourceUrl") if entry.get(key)}
    return {**fields, "kind": kind, **extra, "file": output.as_posix(),
            "bytes": output.stat().st_size, "sha256": sha256(output)}


results = []
for kind, entries in (("artwork", CATALOG["artworks"]), ("music", CATALOG["tracks"])):
    for entry in entries:
        info = commons_file_info(entry["sourceUrl"])
        license_name = info.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "")
        print(f"{entry['id']}: {license_name}", flush=True)
        if not license_name.lower().strip().startswith(ALLOWED_LICENSE_PREFIXES):
            raise RuntimeError(f"Unacceptable license for {entry['id']}: {license_name!r}")
        if license_name != entry["license"]:
            raise RuntimeError(f"Catalog license for {entry['id']} is {entry['license']!r}, Commons says {license_name!r}")

        original_url, original = cached_original(entry["id"], info)
        output = pathlib.Path(entry["file"])
        if not output.exists():
            if kind == "artwork":
                encode_artwork(original, output)
            else:
                encode_track(original, output, entry["title"])
        results.append(record(entry, kind, output, originalUrl=original_url, license=license_name))

for name, file in CATALOG["sfx"].items():
    output = pathlib.Path(file)
    synthesize_sfx(SFX_NOTES[name], output)
    entry = {"id": name, "title": name.replace("-", " ").title(), "creator": "Jezz Atelier"}
    results.append(record(entry, "sfx", output, license="CC0 1.0 (project original)"))

pathlib.Path("assets/media.json").write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n")
for kind in ("artwork", "music", "sfx"):
    print(kind, sum(item["bytes"] for item in results if item["kind"] == kind), "bytes")
print("total", sum(item["bytes"] for item in results), "bytes")
PYTHON
