# Orbitune CI/CD Pipeline Setup Prompt

**Role & Goal:**
You are an expert DevOps and Flutter engineer. I want you to set up an advanced, production-ready CI/CD pipeline using GitHub Actions for my Flutter project named **[INSERT YOUR APP NAME HERE]**. 

Please follow these exact technical specifications step-by-step:

**1. Repository & Git Hygiene Setup**
- Ensure the project is initialized as a Flutter app.
- Update the `.gitignore` file to strictly exclude Android signing files: `android/key.properties`, `*.jks`, and `*.keystore`.

**2. Workflow Architecture**
- Create three **separate** GitHub Actions workflow files so they run in parallel: `[app_name]_android_build.yml`, `[app_name]_ios_build.yml`, and `[app_name]_windows_build.yml`.
- Inside EVERY workflow, jobs must run strictly sequentially: 
  1. `test` (runs `flutter analyze` and `flutter test`)
  2. `build-debug` (requires `test` to pass)
  3. `build-release` (requires `build-debug` to pass)

**3. Android Workflow Details (`[app_name]_android_build.yml`)**
- **Runner:** `ubuntu-latest`
- **Java Setup:** Use `actions/setup-java@v3` with Zulu distribution, version 17.
- **Release Keystore Injection:** In the release job, decode a base64 keystore from GitHub Secrets and save it to `android/app/upload-keystore.jks`. Generate a `key.properties` file in `android/key.properties` using the following secrets: `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, and set `storeFile=upload-keystore.jks`.
- **Build Command:** Build using `flutter build apk --<debug/release> --split-per-abi`.
- **Renaming & Filtering:** After the build, write a bash script to iterate through `build/app/outputs/flutter-apk/app-*-<build_type>.apk`. Exclude the `x86_64` architecture. Rename the remaining APKs to `[app_name]_[architecture]_[build_type].apk` (e.g., `myapp_arm64-v8a_release.apk`).
- **Artifact Uploads:** Use `actions/upload-artifact@v4` to upload the `arm64-v8a` and `armeabi-v7a` APKs in **completely separate upload steps** so they appear as separate downloads in GitHub Actions.

**4. Android `build.gradle.kts` Modifications**
- Modify `android/app/build.gradle.kts` to correctly read the dynamically generated `key.properties` file.
- **CRITICAL KOTLIN SCRIPT FIXES:** You must add `import java.util.Properties` and `import java.io.FileInputStream` at the very top of the file. Do not use array access (`[]`) for properties; use `.getProperty("keyAlias")` instead to avoid `Unresolved Reference` and casting errors during CI/CD Gradle compilation.

**5. iOS Workflow Details (`[app_name]_ios_build.yml`)**
- **Runner:** `macos-latest`
- **Build Command:** Build using `flutter build ios --<debug/release> --no-codesign`.
- **Zipping & Renaming:** After the build, `cd` into `build/ios/iphoneos` and use bash `zip -r` to compress `Runner.app` into `[app_name]_ios_universal_[build_type].zip`.
- **Artifact Uploads:** Upload the single `.zip` file using `actions/upload-artifact@v4`.

**6. Windows Workflow Details (`[app_name]_windows_build.yml`)**
- **Runner:** `windows-latest`
- **Build Command:** Build using `flutter build windows --<debug/release>`.
- **Zipping & Renaming:** Use PowerShell's `Compress-Archive` to zip the contents of `build\windows\x64\runner\<Debug/Release>\*` into `[app_name]_windows_x64_[build_type].zip`.
- **Artifact Uploads:** Upload the zipped file using `actions/upload-artifact@v4`.
