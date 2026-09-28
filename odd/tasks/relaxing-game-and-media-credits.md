# Relaxing game copy and media credits

## Objective
Describe Jezz Atelier as a relaxing, ASMR-inspired game and correct the date/rights statements for third-party music and original sound effects before publication.

## Constraints
- The user's “ASRM” is interpreted as “ASMR” for public-facing copy; avoid medical/therapeutic claims or implying autoplay-only gameplay.
- Do not mistake Wikimedia Commons file dates or upload times for verified recording dates. Preserve each track's performer/composer, source and CC0 attribution.
- Keep original code under MIT and project-generated SFX under CC0 1.0, with explicit disjoint scope; preserve third-party asset licenses.
- Preserve unrelated pending 1.0.0 release changes and avoid GitHub mutation.

## Tasks
- [x] MEDIA-1 Verify track-date provenance, correct the notices generator, regenerate notices for all bundled media, distinguish composer/performer, document the SFX license split, and allow unknown dates in CONTRIBUTING. Route: delegated scout and writer (4+ file mapping, multi-file edit) with scoped follow-up. Evidence: focused RED on ten wrong dates and isolated fixture for unstructured music creator/missing artwork date; GREEN for all, generated notices deterministic (SHA-256 `bd924a2d636798067586472aefebedcc14d2f41f49b974fb1f00029c4c885b4e`), README/LICENSE now distinguish MIT code from CC0 SFX.
- [x] MEDIA-2 Write concise ASMR-inspired relaxing game pitch in README and align affected release copy. Evidence: README leads with Bach piano, soft collisions, blur-to-sharp painting and gentler Relaxed mode without promising no timer; feature bullet names classical piano instead of legal shorthand; exact CC0 license retained and explained in credits. The footer links Gentle-AI with its rose image, and credits JezzBall with a Wikipedia explainer while noting the game is independent.
- [x] MEDIA-3 Verify full suite and documentation consistency, commit a reviewable unit without including unrelated pending release changes; record any skipped live audio check. Route: delegated verifier. Evidence: final stable check passed 77 tests, 25 QML lint files, 27 assets and generator byte-for-byte reproducibility; commit `059548d` includes only the media/README credit unit and this task file. Audible playback in the live shell was not tested.

## Next step
Scout confirmed all ten tracks lack date metadata; first Commons track shows a 2015 file/digitizing date, not proven recording date. Writer corrected README/LICENSE/generator/notices and CONTRIBUTING date policy; user requested friendly classical-music copy and a Gentle-AI rose credit in README. Official Gentle-AI README uses a centered rose footer, and the user explicitly selected its rose.png URL. README now includes the footer and JezzBall inspiration link. MIT scope wording aligned to code and associated documentation, with media separate. Completed media-credit work unit as `059548d`. Remaining 1.0.0 release and marketplace form tasks are tracked separately; no issue was submitted by this unit.
