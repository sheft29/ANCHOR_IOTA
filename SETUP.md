# ANCHOR IOTA — turn on accounts + saved memory (web, ~10 min)

The app already runs offline (saves to the device). These steps add real accounts and
cross-device sync. You do them because they need your Supabase account and your domain — I
can't create accounts, hold keys, or deploy for you.

## 1. Create the backend (Supabase)
1. Go to supabase.com → **New project** (free tier is fine). Pick a name + password, wait ~2 min.
2. **SQL Editor → New query →** paste all of `supabase_schema.sql` → **Run**. (Creates the two
   tables + the row-level-security rules.)
3. **Authentication → Providers:**
   - **Email:** enabled, with "Email OTP / magic link" **ON**. (Lowest-friction, no passwords.)
   - **Google (recommended to add):** toggle on, then paste a Google OAuth **Client ID + secret**.
     You get those at console.cloud.google.com → create an OAuth client (type: Web), and set the
     **Authorized redirect URI** to the value Supabase shows on the Google provider screen
     (`https://<your-project>.supabase.co/auth/v1/callback`). The in-app "Continue with Google"
     button then works. (Apple sign-in can be added the same way later, and matters more for the
     native iOS app.)
4. **Authentication → URL Configuration:** set **Site URL** to `https://anchoryourself.xyz`
   (and add `http://localhost` as an extra redirect URL for testing). The sign-in email links
   back here.
5. **Project Settings → API:** copy the **Project URL** and the **anon public** key.

## 2. Plug the keys into the app
Open `Anchor-Iota.html`, near the top of the main `<script>` find:
```js
const SUPABASE_URL="";
const SUPABASE_ANON_KEY="";
```
Paste your Project URL and anon key between the quotes. Save. That's it — the "Account" section
in the **You** tab now works: enter an email, get a sign-in link, and your profile, journal, and
what Anchor has learned sync to that account on any device.

> The anon key is public by design and safe to ship. Never paste the **service_role** key here.

## 3. Put it online at anchoryourself.xyz
Your landing page is already a GitHub Pages site (github.com/sheft29/anchorsite). Either:
- add `Anchor-Iota.html` (rename to `app.html`) to that repo and link to it, or
- make a new repo, drop the file in as `index.html`, enable **Settings → Pages**, and point a
  subdomain (e.g. `app.anchoryourself.xyz`) at it via a DNS CNAME.

Open the page, go to You → Account, send yourself a link, click it — you're signed in and syncing.

## Encryption of free text (built, optional)
- Supabase already encrypts data **in transit (TLS)** and **at rest**, and row-level security means
  only the signed-in user can read their rows. That's the standard baseline and is fine for a
  clearly-labeled pilot with a privacy policy.
- For stronger protection there's an **optional passphrase** (You → Account → "Private-writing
  passphrase"). When on, your journal, values and goal are AES-GCM encrypted **on the device**
  before they sync, so the server only ever holds ciphertext. Trade-off: it's passwordless by
  design, so if a student forgets the passphrase, that writing can't be recovered, and they must
  re-enter it on each new device. Leave it off for the pilot unless you want that trade-off; the
  code is there when you do.

## Privacy policy
- `privacy-policy.html` is a ready draft. Fill the [bracketed] fields (date, contact email, entity,
  minimum age), have it reviewed (the UM Law clinic contact in your notes), host it at
  `anchoryourself.xyz/privacy`, and link it from the app's onboarding and the You tab.

## Still to do before real students
- **One-tap in-app account + server-side data deletion** (an RPC), not just the device wipe.
- Publish the privacy policy and link it at the point of sign-in.
- These are product/legal calls — yours to make; I can build whatever you choose.

## What "the recommendation engine / ML" is here
It's an on-device adaptive model: every completion updates weights per pillar (Peace/Stability/
Expression) and per activity-mode, plus an effort dial from your context and feedback; those
weights + your pillar balance choose and reorder the next anchor. Once you're signed in, that
learned state is saved to your account and the raw feedback is logged to `anchor_events`, so it
improves across devices and gives you the data to tune it. It is transparent weighting, not a
black box and not an LLM; an LLM step can be added later as a Supabase Edge Function with your
own API key if you ever want it.
