import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register the app with Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            // Register for remote notifications if granted
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            // Handle error or failure to grant permissions
            print("Notification authorization denied: \(String(describing: error))")
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
