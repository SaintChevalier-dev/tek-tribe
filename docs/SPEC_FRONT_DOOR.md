# Game front door spec: play.cloverkingdom.net (DRAFT)

Status: draft only. Nothing is deployed.

Draft only. Deploy nothing. Sign up for nothing. Touch no DNS.

## Address

`play.cloverkingdom.net` - Cloudflare Pages.  
Live site stays `cloverkingdom.net` on GitHub Pages. Apply remains the only join path.

## Four doors

1. Invite-only Supabase login  
2. Membership check  
3. Spawn into the world  
4. First view

## Pages

| Page | What it does |
|---|---|
| `/login` | Supabase invite-only. Player enters invite code or clicks invite link. No open signup. |
| `/gate` | Membership check. Confirms the logged-in player is a member. |
| `/spawn` | Places the player into the world at their start point. |
| `/world` | First view. Party, active quest, one next move. |
| `/blocked` | Failure state. Shows the blocked note and the one way forward. |

## Data

| Piece | Source | Used by |
|---|---|---|
| Invite code / link | Issued after Apply approval on the live site | `/login` |
| Supabase session | Supabase auth | all pages after login |
| Membership flag | Membership table (row created on approval) | `/gate` |
| Player id | Supabase user id | all pages |
| Spawn point | Player record (default: start) | `/spawn` |
| First-view payload | Party rows, active quest, one next move | `/world` |
| Blocked note | Written on any failure | `/blocked` |

## Failure states

| Failure | Blocked note | Way forward |
|---|---|---|
| No invite | "No invite. Apply on cloverkingdom.net." | Link to Apply |
| Invite expired | "Invite expired. Request a new one." | Link to Apply |
| Login fails | "Login failed. Try the invite again." | Back to `/login` |
| Not a member | "Not a member. Game access is membership." | Link to Apply |
| Membership check fails | "Membership check failed. Retry." | Retry `/gate` |
| Spawn fails | "Spawn failed. Retry." | Retry `/spawn` |
| First view empty | "No first view. One next move is missing." | Retry `/world` |

A failure logs a blocked note. No XP is lost. The player can retry, or drop back to Apply.

## Rules

- Membership is game access. No bypass.
- Player logs in, then spawns. No spawn without membership.
- A win needs a trace plus the player marking it done. Not on this door.
- XP is flat. Not on this door.

## Smallest step to build first

The approval-to-login handoff as a draft page.  
It shows: Apply approved -> invite issued -> player uses invite at `/login`.  
No live login. No Supabase project. No DNS change.

## Done looks like

A static draft page that names the four steps in order, shows the blocked notes, and does not connect to anything. You open it and confirm the order.
