# RepuLink — User Guide

RepuLink helps you build and check trust with other people you interact with online.
Every time you complete an interaction and rate it, or endorse someone you vouch for,
your trust relationships and reputation update automatically.

## Creating an account

1. Go to the Sign Up page.
2. Fill in: full name, email, organization, incorporation, address, VAT number,
   position title, phone number, and a password (8+ characters).
   These extra fields are required by the identity system RepuLink runs on — they
   can't be skipped.
3. Submit. You can now log in with that email and password.

## Logging in

Use your email and password on the Login page. If you forget your password, contact
your administrator — there's currently no self-service "forgot password" flow.

## Dashboard

Your home page after logging in. Shows:

- **Current Score** — your reputation, a single number reflecting how much the
  network as a whole trusts you (built from both your interaction history and any
  endorsements you have).
- **Rank** — your position relative to everyone else in the system.
- **A trend chart** — how your reputation has moved over time. It updates every time
  anyone rates an interaction with you, or endorses/is endorsed, anywhere in the
  network (not just your own actions) — so don't be surprised if it shifts a little
  even when you haven't done anything recently. A rating from someone with very
  little reputation of their own moves the needle far less than one from someone
  well-established.

## Interactions

Use this page to connect with someone, then rate how it went.

1. **Find a person** — type a name, email, or RepuLink ID into the search box.
   - Partial name/email matches work if they've used RepuLink before.
   - An *exact* email match also works even for someone who has never logged into
     RepuLink yet, as long as they have an account in the underlying identity system —
     they'll be added automatically the moment you find them.
   - Each result shows that person's current reputation on the right.
2. **Send a request** — pick them from the dropdown, optionally add a message, and
   send.
3. **Respond to requests** — incoming requests show up with Accept/Deny buttons.
   Only accepted interactions can be rated.
4. **Rate it** — once accepted, either side can leave a rating (with an optional
   comment). Ratings feed directly into both your local trust score with that person
   and the network-wide reputation calculation.

## Endorsements

An endorsement is a stronger, more deliberate statement than a rating — "I vouch for
this person/organization," with a confidence level you set yourself (a slider from
low to high confidence).

1. Search for the person you want to endorse (same search box behavior as
   Interactions — exact email lookups work even for people new to RepuLink).
2. Set your confidence level and submit.
3. The page also shows who you've endorsed, and who has endorsed you.

Endorsing someone with low credibility yourself carries less weight than an
endorsement from someone well-established — and if the person you endorsed later
behaves badly, some of that reflects back on you. Endorse thoughtfully.

## Trust Network

A visual map of everyone you've personally rated, centered on you.

- **Node color** — that person's trust score from your point of view: red (low) to
  green (high), yellow in between.
- **Node size** — how many ratings you've exchanged with them; bigger means more
  history.
- **Click any node** to open a panel with your full interaction history with that
  person and their score breakdown.

This is *your* personal view — it only includes people you've directly rated,
unlike the Dashboard's network-wide reputation score.

## Settings

- **My Profile** — view/update your name and email.
- **Password** — change your password.
- **Danger Zone** — permanently delete your account.

## Items

A general-purpose notes/items list, unrelated to trust or reputation — useful if you
just want a simple personal list inside the same app.

## Admin (administrators only)

If your account has admin rights, an **Admin** page appears in the sidebar for
managing other users (creating accounts, adjusting active/admin status). Regular
users won't see this page at all.
