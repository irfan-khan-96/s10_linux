# Galaxy S10 (Exynos, SM-G973F) — postmarketOS pocket terminal

Personal, unofficial fork of postmarketOS for the Samsung Galaxy S10 (`samsung-beyond1lte-downstream`),
turned into a pocket Linux terminal and home server: fbterm + tmux, a custom on-screen keyboard,
Wi-Fi, key-only SSH, firewall. Built with AI assistance; not affiliated with or submitted to postmarketOS.

| Path | Contents |
| --- | --- |
| `patches/` | The fork as patch files (`git am` on the upstream pmaports commit in `patches/BASE`) |
| `s10-downstream.bundle` | The same commits as a git bundle |
| `*.apk` | Built packages (fbterm, s10-terminal) |
| `phone-config/` | Snapshot of every custom file from the phone, by path |
| `scripts/`, `tools/` | Helper scripts used during the port (Odin packaging, serial rescue, tests) |
| `pmbootstrap_v3.cfg` | pmbootstrap configuration |

Full notes: the "postmarketOS on Galaxy S10" document (install recipe, the fixes, security, recovery).
