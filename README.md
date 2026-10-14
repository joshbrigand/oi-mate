# Oi Mate. — MVP build (v4)

## Files
- `index.html` — the whole app (Alpine.js + Tailwind, no build step)
- `manifest.json`, `sw.js`, `icon-192.png`, `icon-512.png` — installable PWA
- No API keys, no backend, no cost. Data lives in the browser on the device you use.

## What changed in v4
- **Tradies are editable**: Edit button on the Team tab (name, trade, mobile, new email field).
- **Multiple tradies per task**: tap as many as you like. Saving offers one-tap texts, and
  the text now includes the task title.
- **Tasks can have a date and time** ("When"). The house page shows a calm "Coming up" card
  and each room shows its next task.
- **Attachments open in a new tab** (tap the file chip on a task). Files are stored on the
  device they were added from.
- **Tags page**: tap stickers to select them (border + tick, "2 of 3 selected"), pick Large
  15 cm or Small 8.5 cm, then Print. QR codes are now drawn locally as sharp vectors.
- **Printing**: stickers only, no headers or footers, A4, flowing onto extra pages so nothing is
  cut off (Large = 1 per page, Small = 6 per page). If your browser still shows a header or
  footer, untick "Headers and footers" in its print dialog.
- Delete room is now a pill button like the others.

## Before you print real stickers
The QR codes point at whatever web address the app is running on. Netlify Drop gives a new
address each time you drop the folder, so use a fixed one (claim your Netlify site name or
use your own domain) before printing, or the stickers will stop working.

## Not built yet
- Google sign-in and calendar import.
- Sharing data between devices (see notes in chat).

## Installing it as an app (for testing)
1. Put the folder on Netlify (drop it at https://app.netlify.com/drop), then rename the site to something permanent.
2. iPhone: open the link in Safari, Share, Add to Home Screen.
   Android: open it in Chrome, menu (three dots), Install app.
3. It opens full-screen with the Oi Mate icon, no browser bar.
If you installed an earlier version, delete the old icon first so the new one shows.

## Cloud setup (v5)
1. Supabase > SQL Editor > New query: paste `supabase-setup.sql`, then Run.
2. Supabase > Authentication > Sign In / Providers > Google: switch on, paste your Google client ID and secret.
3. Supabase > Authentication > URL Configuration: set Site URL to your GitHub Pages address and add the same address under Redirect URLs.
4. Open the app, Team tab, Continue with Google.
Tradies scanning a sticker see only that room (names and trades, no phone numbers). They can't edit anything yet.
Free Supabase projects pause after a week with no activity; restore from the Supabase dashboard if that happens.
