# Security Rules

## Command Denylists
Always require confirmation:
- `rm -rf` with broad paths
- `git push --force`
- `dd if=/dev/zero`
- `chmod 777`
- Piped installs (`curl | sh`)

## File Access Restrictions
Never read without permission:
- `~/.ssh/*`, `~/.aws/credentials`, `~/.gnupg/*`
- `.env` files outside this project

## Secrets Management
- Never commit `.env` — use `.env.enc` with sops+age
- Never log API keys, tokens, or passwords
- Encryption config: `.sops.yaml`
