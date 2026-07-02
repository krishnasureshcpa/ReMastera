# Release Process

This document outlines the steps required to compile, code-sign, notarize, and publish a new release of ReMastera.

## 1. Clean the Environment

Before creating a release build, ensure the local build directories are cleaned to prevent old cached object files from being bundled:

```bash
rm -rf .build/
rm -rf build/
```

## 2. Compile and Package

Run the packaging script to build the release binary and bundle it inside a standard macOS application structure:

```bash
./scripts/package.sh
```

This creates the app bundle at `build/ReMastera.app` and compresses it to `build/Dist/ReMastera-macOS.zip`.

## 3. Code Signing and Notarization

To distribute ReMastera to external users without triggering gatekeeper warnings, the application must be signed with a valid Apple Developer ID Application certificate and notarized by the Apple notary service.

### Step A: Codesign the App Bundle

```bash
codesign --force --options runtime --deep --sign "Developer ID Application: Your Name (TeamID)" "build/ReMastera.app"
```

### Step B: Submit for Notarization

Compress the signed app bundle and submit it to Apple:

```bash
xcrun notarytool submit build/Dist/ReMastera-macOS.zip --keychain-profile "MyNotaryProfile" --wait
```

### Step C: Staple the Ticket

If notarization succeeds, staple the ticket to the app bundle:

```bash
xcrun stapler staple "build/ReMastera.app"
```

## 4. Git Tagging and Publishing

Create a new tag matching the version string in the application settings:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

Upload the final notarized zip artifact (`ReMastera-macOS.zip`) to the GitHub release page.
