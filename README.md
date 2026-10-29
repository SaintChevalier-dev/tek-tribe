# Tek Tribe

> Take the quest. Hand it to your bot. Prove the win.

Tek Tribe is an invite-only, members-only game world. You log in, spawn into the world, pick up quests, and hand them to your bots (SIs). XP is flat and honest: a win only counts when there is a system trace **and** you mark it done. No grinding fake numbers.

**Status: early. This repo holds local, offline drafts. Nothing is playable online yet.**

## The playable slice

| Step | What it is | Status |
|---|---|---|
| 1. Login | Invite-only login after an approved application | Draft page (built locally, connects to nothing) |
| 2. Spawn | Member check, then the player enters the world | Spec drafted; first-view page in progress |
| 3. World | First view: party, active quest, one next move | Not built |
| 4. First quest | One real quest to take | Not built |
| 5. Bot handoff | Give the quest to one of your bots | Not built |
| 6. Win + XP | Trace + player confirms, flat XP awarded | Not built |

Pockets are offline views of real builds. **Pocket #1: MiniBot.si** - built locally.

Ideas on the board (not promises): bot skill pages with levels that rise only on evidence, and a trading hub for members.

## Screenshots

`docs/img/front-door.png` - placeholder
`docs/img/minibot-pocket.png` - placeholder
`docs/img/demo.gif` - placeholder (walkthrough of the slice)

## Run the local drafts

Everything here is offline. No network, no accounts.

- Front door: open `front-door/front_door_draft.html` in a browser.
- MiniBot pocket (Windows PowerShell):
  `powershell -ExecutionPolicy Bypass -File pockets/minibot/minibot_pocket.ps1 -Roots <path-to-your-repo> -OutDir pockets/minibot/out`
  Missing values show as `unknown`.

## Contribute

- Open an issue first: bug, idea, or quest proposal.
- Keep it offline-first: no external scripts, fonts or trackers in drafts.
- One change per PR, with a short note on how you tested it.
- Labels: `good first issue`, `pocket`, `slice`.

## License

Suggested: MIT for code. Art and lore can be added later under CC BY 4.0.

Tek Tribe is an independent fan-built project.