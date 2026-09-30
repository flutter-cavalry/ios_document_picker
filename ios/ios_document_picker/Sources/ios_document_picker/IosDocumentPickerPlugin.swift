import Flutter
import UIKit
import UniformTypeIdentifiers

enum PickerMode: Int { case file, folder }

public class IosDocumentPickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  var resultFn: FlutterResult?
  private var securityScopedURLs: [String: URL] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ios_document_picker", binaryMessenger: registrar.messenger())
    let instance = IosDocumentPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "InvalidArgsType", message: "Invalid args type", details: nil))
      return
    }
    switch call.method {
    case "pick":
      resultFn = result

      let mode = PickerMode(rawValue: args["type"] as! Int)
      let allowsMultiple = args["multiple"] as? Bool ?? false
      let allowedUtiTypes = args["allowedUtiTypes"] as? [String]

      let utTypes = allowedUtiTypes?.compactMap { UTType($0) }

      let documentPicker =
        UIDocumentPickerViewController(
          forOpeningContentTypes: utTypes ?? (mode == .folder ? [UTType.folder] : [UTType.data]))
      documentPicker.delegate = self
      documentPicker.allowsMultipleSelection = allowsMultiple

      // Present the document picker.
      currentViewController()?.present(documentPicker, animated: true, completion: nil)

    case "release":
      if let accessToken = args["accessToken"] as? String,
        let url = securityScopedURLs.removeValue(forKey: accessToken)
      {
        url.stopAccessingSecurityScopedResource()
      }
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func currentViewController() -> UIViewController? {
    guard
      let windowScene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    else {
      return nil
    }

    let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })

    var topController = keyWindow?.rootViewController
    while let presented = topController?.presentedViewController {
      topController = presented
    }

    return topController
  }

  private func urlToMap(_ url: URL) -> [String: Any] {
    return [
      "url": url.absoluteString, "path": url.path, "name": url.lastPathComponent,
    ]
  }

  public func documentPicker(
    _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
  ) {
    let maps = urls.map { url in
      var map = urlToMap(url)
      if url.startAccessingSecurityScopedResource() {
        let accessToken = UUID().uuidString
        securityScopedURLs[accessToken] = url
        map["accessToken"] = accessToken
      }
      return map
    }
    resultFn?(maps)
  }

  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    resultFn?(nil)
  }
}
