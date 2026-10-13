# E-Invoice Data Extractor — GitHub Actions signed APK build

This starter package prepares a GitHub Actions workflow for **one signed APK only**. It uses the app configuration you supplied:

- App name: E-Invoice Data Extractor
- Android package ID: `app.einvoice.extractor`
- Hosted origin: `https://ais-dev-da3u6el3da7a5gm4bgr7uu-96805081502.asia-southeast1.run.app`

## Important: one-time setup is still required

The uploaded `twa-manifest.json` is a configuration seed, not a complete generated Bubblewrap Android project. The workflow deliberately stops with a clear error until the generated Android project files (`gradlew`, `app/`, etc.) are present. The workflow does **not** run `bubblewrap init` in CI because initialization is interactive and may prompt for app settings/signing details.

## 1. Create the Android project once

Use a computer with Node.js 18+ and Java 17, and install Bubblewrap:

```bash
npm install --global @bubblewrap/cli
```

Create a clean working directory and initialize from the actual web manifest URL:

```bash
mkdir einvoice-android
cd einvoice-android
bubblewrap init --manifest="https://ais-dev-da3u6el3da7a5gm4bgr7uu-96805081502.asia-southeast1.run.app/manifest.webmanifest"
```

When prompted, use the same package ID `app.einvoice.extractor` and the supplied app name/theme settings. Keep the generated `twa-manifest.json` and Android project files. The supplied file is preserved in this package as `twa-manifest.seed.json` for reference; do not overwrite the generated config wholesale, because Bubblewrap requires additional fields such as `signingKey` and `splashScreenFadeOutDuration`.

If you already have a Bubblewrap project, use that instead and copy the `.github/workflows/build-apk.yml` file into its repository. Ensure the generated project is in the repository root, next to `twa-manifest.json` and `gradlew`.

## 2. Create a signing keystore

For a new app, create a keystore once and keep it safe. Do **not** generate a new key for each build; future updates must use the same signing key. Example (run locally with Java's `keytool`):

```bash
keytool -genkeypair -v \
  -keystore android-keystore.jks \
  -alias einvoice-release \
  -keyalg RSA -keysize 2048 -validity 10000
```

Use a strong keystore password and key password. Record them securely. Do not commit `android-keystore.jks` or passwords to GitHub.

Encode the keystore as a single-line Base64 string:

- Linux/macOS/Git Bash: `base64 -w 0 android-keystore.jks`
- PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes('android-keystore.jks'))`

## 3. Add GitHub repository secrets

In your GitHub repository, open **Settings → Secrets and variables → Actions → New repository secret** and add all four:

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | The Base64 output from the keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password (may be the same if you chose so) |
| `ANDROID_KEY_ALIAS` | `einvoice-release` (or the alias you chose) |

Only these four secrets are required by this workflow. Never paste the keystore or passwords into a public issue or commit them into the repository.

## 4. Push project to GitHub and run the workflow

1. Create a **private** GitHub repository (recommended for source/config privacy).
2. Add the generated Bubblewrap Android project files and this `.github/workflows/build-apk.yml` workflow. Include `twa-manifest.json`, `gradlew`, `gradle/`, `app/`, and the Gradle build files.
3. Do **not** commit the keystore, passwords, `local.properties`, or other machine-specific secrets.
4. Open **Actions → Build signed E-Invoice APK → Run workflow**.
5. When it succeeds, open the workflow run and download the artifact named `einvoice-extractor-signed-apk`. It contains `app-release-signed.apk`.

The workflow uploads only the signed APK; it does not publish to Google Play or upload an AAB.

## 5. TWA domain verification

For the app to open in verified Trusted Web Activity mode without browser UI, the hosted site must serve `/.well-known/assetlinks.json` with the package name `app.einvoice.extractor` and the SHA-256 fingerprint of the signing certificate used for this APK. The fingerprint can be obtained from the keystore with `keytool -list -v -keystore android-keystore.jks -alias einvoice-release`. Make sure the hosted app owner can update this file. Without valid Digital Asset Links, the app may fall back to browser UI.

## What the workflow does

- Uses Ubuntu GitHub-hosted runners, Java 17, Node.js 20, Android SDK, and Bubblewrap CLI.
- Restores the signing keystore from GitHub Secrets only during the build.
- Builds the signed APK and checks that it exists.
- Uploads only `app-release-signed.apk` as a downloadable Actions artifact for 14 days.

The first build can fail if the hosted web manifest/icons are unavailable, PWA validation fails, Android project files are incomplete, or the signing secrets are incorrect. Review the Actions log for the exact failure.
