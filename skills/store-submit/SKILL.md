---
name: store-submit
description: Take a finished app to the App Store and Google Play - enrollment, builds, listings, privacy declarations, review. Use for "publish the app", "submit to the store", "app store", "google play", "TestFlight", "store listing", "data safety form", "app review".
---

# Store submission

The agent prepares; the account holder decides. This skill divides the path into steps
the agent does and steps marked **[user]** that only the account holder may do: create
an account, pay a fee, accept an agreement, answer a binding questionnaire, and press
the final submit. The agent never does a [user] step, and never asks for the account
password.

## 1. Read these two things first

- The project's decision record. A restricted register (wellness, medical, financial)
  binds the store listing too: the copy rules, the claims, and the category answers.
- The current official requirement pages, at the moment of use. Store facts change:
  fees, screenshot sizes, tester counts, API levels, rating tiers. The numbers in this
  file carry their read date. When this file and the linked page disagree, obey the
  page, and update this file.

Ground truth pages: Apple enrollment (developer.apple.com/support/enrollment), review
guidelines (developer.apple.com/app-store/review/guidelines), screenshot specifications
(developer.apple.com/help/app-store-connect/reference/screenshot-specifications), app
privacy details (developer.apple.com/app-store/app-privacy-details); Play requirements
(support.google.com/googleplay/android-developer: answers 6112435, 14151465, 9866151,
10787469), target API levels (developer.android.com/google/play/requirements/target-sdk);
EAS (docs.expo.dev/submit, docs.expo.dev/app-signing).

## 2. Prepare what both stores need (agent work)

- The identity: `ios.bundleIdentifier` and `android.package` are immutable after the
  first upload. Select them with the user before any build.
- The config: version numbers, icons, splash screen, and one purpose string for each
  sensitive API the app touches. A missing purpose string is a named Apple rejection.
- The builds: `eas build --platform ios|android --profile production`. EAS builds in
  the cloud; no Mac is necessary.
- The listing copy, under [write-docs](../write-docs/SKILL.md) rules: each claim real,
  each screenshot from the real app at the sizes the current spec page names.
- The privacy declarations, derived from evidence, not from intent: the code (`grep`
  for network calls, SDKs, and identifiers), each SDK's documented behavior, and the
  server side's handling of the data. Play's definition: "collected" means transmitted
  off the device; local-only data is not collection. The store review does not verify
  the answers. The accuracy is the developer's own duty.
- Two URLs, live before submission: a privacy policy (not a PDF, not geo-fenced) and a
  support page. A policy URL that fails to load counts as no policy.

## 2a. Maximum automation: the API channel, with stored credentials

Do not automate the store consoles through a browser. Both stores have an official API,
and the standard tools already drive it. Use them; do not build a new app for this.

- **Credentials, one-time [user]:** an App Store Connect API key and a Play service
  account JSON. Store them with `eas credentials`, which keeps them encrypted on the
  Expo account. A plain file with owner-only permission is not encrypted: when EAS
  storage is not possible, use the operating system's keychain. A credential never
  appears in the repository, the chat, or a log. After this one setup, the agent runs
  the permitted steps below unattended.
- **Builds and uploads, with a safe profile:** `eas build` and `eas submit`, both
  platforms, no prompts. Configure the submit profiles so that no automated step starts
  a review or a rollout: the iOS upload goes to TestFlight only, and the Android
  release lands as a draft on the internal track. A step that starts a review or a
  rollout is [user] work.
- **The listing forms, filled from a file:** write the Apple listing - name, subtitle,
  description, keywords, categories - into `store.config.json`, and push it with
  `eas metadata:push`. The file lives in the repository, so the listing is reviewed
  like code. Exclude the questionnaire sections from the push: age rating and advisory
  answers are [user] work - prepare them as text for the user to enter and confirm.
  Put reviewer demo credentials only in the dedicated `demoUsername` and
  `demoPassword` fields, injected from the encrypted store, never in tracked files and
  never in the notes.
- **Google listings:** push listing text and graphics through the Play Developer API
  (the Edits API). Commit edits with the option that does not send changes for review.
  Never commit over a release that is in review without the user's decision. Release
  notes travel through the track metadata; `eas submit` does not carry them.
- **The ceiling, stated honestly:** the Data safety form has an API
  (`applications.dataSafety`). The IARC rating, the Health apps declaration, and every
  agreement and fee do not. API or no API, a binding declaration is confirmed by the
  user before it goes live. The agent prepares every answer as text.

The end state: the agent builds, uploads, and fills every form that has an API, and
starts no review and no rollout. The user checks the populated console against the
prepared answers, confirms the binding declarations, and presses submit.

## 3. The Apple path

1. **[user]** Enroll in the Apple Developer Program (99 USD/year, read 2026-10).
   Individual is fast; an organization needs a legal entity, a D-U-N-S number, and
   verification time. A regulated-category app must come from the legal entity.
2. **[user]** Create the App Store Connect app record: name (unique, 30 characters),
   bundle ID, SKU. Have two or three name candidates. Record the numeric app ID for
   `eas.json` (`ascAppId`).
3. **[user, one time]** Sign in to Apple when the first `eas build` asks. Then store an
   App Store Connect API key with `eas credentials`: after that, builds and submissions
   run unattended.
4. Build and upload: `eas build -p ios --profile production`, then `eas submit -p ios`.
   The upload reaches TestFlight; it is not yet a review submission.
5. **[user]** TestFlight: add testers in App Store Connect. Internal testers need no
   review; external groups need a beta review of the first build.
6. **[user]** Answer the age rating questionnaire (tiers 4+/9+/13+/16+/18+, read
   2026-10) and the App Privacy labels, from the declarations prepared in section 2.
   EU sales also require the DSA trader information.
7. **[user]** Press "Submit for review". Before that, run the rejection check below.

## 4. The Google Play path

1. **[user]** Create the Play Console account (25 USD one time, read 2026-10). Decide
   individual against organization with this fact: a personal account created after
   2023-11-13 cannot publish to production until a closed test runs with at least 12
   testers opted in for 14 continuous days, plus a production-access review of
   approximately 7 days. Budget three weeks or more. Organization accounts are exempt.
2. **[user]** Create the app entry and accept the program policies. "Free" is
   permanent after publication.
3. **[user, one time]** Create the Google Cloud service account for submissions and
   grant it release permission. The JSON key never enters the repository or the chat:
   upload it with `eas credentials -p android`, which stores it encrypted.
4. Build and upload: `eas build -p android --profile production`, then
   `eas submit -p android` to the internal testing track first.
5. Complete the listing: feature graphic 1024x500 is required; at least two
   screenshots; name 30, short description 80, full description 4000 characters (read
   2026-10).
6. Prepare the Data safety answers from section 2's derived declarations. **[user]**
   Confirm the form before it goes live: the declaration binds the account.
7. **[user]** Answer the content rating (IARC) and the Health apps declaration. Every
   app answers the health declaration, including "no health features".
8. Confirm the build targets the current required Android API level. Read the
   requirement page and the installed Expo SDK's target. Google raises the required
   level each year.
9. **[user]** Run the closed test if required, apply for production access, then
   promote the release and confirm the rollout.

## 5. The rejection check, before each first submission

Verify on the real build, not the source:

- The app starts and does not crash.
- No placeholder screens, and no dead buttons.
- Each login-gated screen has demo credentials, supplied in the store's dedicated
  demo-account fields, injected from the encrypted store.
- The screenshots match the real UI.
- A purpose string exists for each permission.
- The privacy policy URL loads.

Broken basic function is the largest rejection class on both stores.

## 6. The limits of this skill

- Policy text, fees, and dimensions in this file were read on 2026-10-26. Read the
  linked pages before each use. A mismatch means the page wins and this file needs an
  update.
- This skill prepares and verifies. It never creates an account, pays, accepts terms,
  or submits. Those acts bind the account holder, so the account holder does them.
- A release to a store is a release: the rules of [release](../release/SKILL.md) apply,
  the stop conditions and the rollback plan included.
