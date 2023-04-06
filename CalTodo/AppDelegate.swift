//
//  AppDelegate.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  func application(
    _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {

    // Print full message.
    print(userInfo)
    let task = beginBackgroundTask()

    let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
    URLSession.shared.fetchData(for: url) { (result: Result<[ToDo], Error>) in
      switch result {
      case .success(let toDos):
        print("Success todos", toDos)
        break
      case .failure(let error):
        print("failure", error)
        break
      }
      endBackgroundTask(taskID: task)
    }

    // completionHandler()

    completionHandler(UIBackgroundFetchResult.newData)
  }
}
func beginBackgroundTask() -> UIBackgroundTaskIdentifier {
  return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
}

func endBackgroundTask(taskID: UIBackgroundTaskIdentifier) {
  UIApplication.shared.endBackgroundTask(taskID)
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Foreground notification handling - e.g. you might display in app UI
    print("Notification received with identifier \(notification.request.identifier)")
    completionHandler([.banner, .sound])
  }
}

extension AppDelegate {
  func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("deviceToken", deviceToken.hexString)
  }

  func application(
    _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print(error)
  }
}

extension Data {
  var hexString: String {
    let hexString = map { String(format: "%02.2hhx", $0) }.joined()
    return hexString
  }
}
