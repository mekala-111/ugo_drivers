// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-11.5.0"),
        .package(name: "file_picker", path: "../.packages/file_picker-10.1.9"),
        .package(name: "firebase_app_check", path: "../.packages/firebase_app_check-0.3.2+7"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-5.6.0"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-3.14.0"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-4.3.7"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-15.2.7"),
        .package(name: "firebase_performance", path: "../.packages/firebase_performance-0.10.1+7"),
        .package(name: "firebase_remote_config", path: "../.packages/firebase_remote_config-5.4.5"),
        .package(name: "firebase_storage", path: "../.packages/firebase_storage-12.4.7"),
        .package(name: "geocoding_ios", path: "../.packages/geocoding_ios-3.1.0"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.4.3"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-5.9.0"),
        .package(name: "haptic_feedback", path: "../.packages/haptic_feedback-0.6.5"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+15"),
        .package(name: "permission_handler_apple", path: "../.packages/permission_handler_apple-9.6.5"),
        .package(name: "pointer_interceptor_ios", path: "../.packages/pointer_interceptor_ios-0.10.1+1"),
        .package(name: "razorpay_flutter", path: "../.packages/razorpay_flutter-1.4.7"),
        .package(name: "share_plus", path: "../.packages/share_plus-12.0.2"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.6.2"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.2"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.12.4"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.5.2"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "firebase-app-check", package: "firebase_app_check"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "firebase-performance", package: "firebase_performance"),
                .product(name: "firebase-remote-config", package: "firebase_remote_config"),
                .product(name: "firebase-storage", package: "firebase_storage"),
                .product(name: "geocoding-ios", package: "geocoding_ios"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "haptic-feedback", package: "haptic_feedback"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "pointer-interceptor-ios", package: "pointer_interceptor_ios"),
                .product(name: "razorpay-flutter", package: "razorpay_flutter"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
