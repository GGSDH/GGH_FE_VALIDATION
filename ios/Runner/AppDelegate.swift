import Flutter
import UIKit
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.ggh.fe.valiation/images"

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let imageChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

      imageChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getAllImages" {
          self?.fetchAllImages(result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func fetchAllImages(result: @escaping FlutterResult) {
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          var imagePaths = [String]()
          let fetchOptions = PHFetchOptions()
          fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
          let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
          fetchResult.enumerateObjects { (asset, _, _) in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, _, info) in
              if let filePath = info?["PHImageFileURLKey"] as? URL {
                imagePaths.append(filePath.absoluteString)
              }
            }
          }
          result(imagePaths)
        } else {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
        }
      }
  }
}
