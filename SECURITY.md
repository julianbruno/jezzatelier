# Security

Report vulnerabilities privately through this repository's GitHub **Report a vulnerability** / private security advisory feature. Do not publish exploit details in an issue before coordination. Maintainers should confirm private vulnerability reporting is enabled for the [public repository](https://github.com/julianbruno/jezzatelier) before release. A marketplace listing or automated listing validation is not a security audit.

Omarchy plugins run unsandboxed inside the shared, long-lived shell process with the user's permissions. Audit code before enabling and review upstream diffs before updates. This plugin is designed to read bundled assets and read/write only `${XDG_STATE_HOME:-$HOME/.local/state}/jezz-atelier/state.json`; it needs no runtime network, external executable, account, or privileged install hook. A bug in a plugin can still affect the shell or the user's files.
