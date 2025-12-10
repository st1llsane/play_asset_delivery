# Asset Delivery Plugin for Flutter

## Introduction

The **Asset Delivery Plugin** simplifies managing **on-demand asset delivery** in Flutter applications. It integrates with Play Asset Delivery (Android) and On-Demand Resources (iOS), enabling dynamic asset downloads and seamless user experiences.

## Requirements

- **Flutter:** 3.38.0 or newer
- **Dart SDK:** 3.10.0 or newer
- **Android toolchain:** Android Gradle Plugin 8.5.x with Kotlin 1.9.24
- **iOS:** iOS 12 or newer

### Key Features

- **On-Demand Asset Delivery:** Download and access assets dynamically at runtime.
- **Customizable Resource Management:** Flexible naming patterns and ranges for asset files.
- **Progress Tracking:** Real-time download progress updates.
- **Cross-Platform Support:** Compatible with both Android and iOS.

---

## Installation

Add the following line to your `pubspec.yaml` file:
```yaml
dependencies:
  asset_delivery: 
    git:
      url: https://github.com/mohsen-motlagh/asset_delivery.git
      ref: main

flutter:
  generate: true      
```

## Setup

### Android

#### Minimum SDK Version: 24

1. Add the Play Asset Delivery library to your Gradle file:
    ```gradle
    implementation "com.google.android.play:asset-delivery:2.2.2"
    ```

2. Run the setup command in the terminal:
    ```bash
    dart run asset_delivery:setup_asset_pack "YourAssetPackName"
    ```

3. A folder named after your asset pack will be created, containing:
    - A `build.gradle.kts` file.
    - A `manifest` folder with an `AndroidManifest.xml` file.

4. Add your assets in the following path:
    ```bash
    ProjectDirectory/Android/YourAssetFolder/src/main/assets/"PUT YOUR ASSETS IN THIS DIRECTORY"
    ```

5. Once published to the Play Store, you can retrieve assets dynamically. To test before publishing, follow the **Testing** steps below.

6. For multiple asset packs, repeat these steps for each asset pack.

---

### Android Testing
## This method of testing is only available for Android versions below 12. Alternatively, you can publish your app to the Google Play Store for internal testing.

1. Download the [BundleTool](https://github.com/google/bundletool/releases).

2. Build your app bundle and use the following commands:

    - **Generate the APKs:**
        ```bash
        java -jar bundletool.jar build-apks --bundle=<your_app_project_dir>/build/app/outputs/bundle/release/app-release.aab --output=<your_temp_dir>/app.apks --local-testing
        ```

    - **Install the APKs on your device:**
        ```bash
        java -jar bundletool.jar install-apks --apks=<your_temp_dir>/app.apks
        ```

3. To get the final APK size:
    ```bash
    java -jar bundletool.jar get-size total --apks=<your_temp_dir>/app.apks --dimensions=SDK
    ```

---

### iOS

1. Open Xcode and navigate to your **Runner** project.

2. Add your assets to the **Assets** folder.

3. Configure the asset pack:
    - Select the asset or folder.
    - In the right panel, find **On-Demand Resource Tags** under the settings icon.
    - Add your **Asset Pack Name** (this should match the name used for Android).

4. Ensure all assets are tagged appropriately.

---

### iOS Testing

You can test your iOS app by running it from Xcode on a real device or simulator, as well as using flutter run --release.

## Usage

1. **Download Assets**  
   On Android devices, download and install assets dynamically using:  
   ```dart
   await assetDelivery.fetch("$assetpackName");

   - If the assets already exist on the device, the download will be skipped automatically.
   - On iOS, this step is not necessary as assets are accessed directly.

2. Track Download Progress
    During the download, track the status of the asset pack by calling:
    ```
    await assetDelivery.getAssetPackStatus();
    ```

### 3. Retrieve Asset Path  
  Get the local path to the downloaded assets using the following code:  

  ```dart
    final path = await assetDelivery.getAssetPackPath(
      assetPackName: widget.assetPackName,
    );
    
    Parameters:
    assetPackName: The name of the asset pack.
    fileExtension: The file fileExtension of the assets (e.g., 'mp3').
  ```

4. Check for keyword "COMPLETED" from the status to be sure the assets completely downloaded

### Example
[Example App](https://github.com/mohsen-motlagh/asset_delivery_example)

---

## Testing

The plugin includes comprehensive tests for the setup command and the plugin functionality.

### Running Tests

To run all tests:
```bash
flutter test
```

To run specific test files:
```bash
# Test the setup_asset_pack command
flutter test test/setup_asset_pack_test.dart

# Test the plugin functionality
flutter test test/asset_delivery_test.dart
```

### Setup Command Tests

The `setup_asset_pack_test.dart` file includes tests for:
- Error handling when no arguments are provided
- Error handling for invalid delivery types
- Creating asset packs with different delivery types (on-demand, install-time, fast-follow)
- Preventing duplicate asset pack creation
- Updating app/build.gradle with assetPacks configuration

These tests use temporary directories to simulate a Flutter project structure and verify that the setup command creates all necessary files correctly.

---

### Support
Please support the plugin by give a thumbs up in pub.dev and github

### Contributions
Contributions are welcome! Feel free to submit issues or pull requests on GitHub.

### License
This plugin is licensed under the MIT License. See the LICENSE file for details.
