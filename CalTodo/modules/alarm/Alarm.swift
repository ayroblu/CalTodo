//
//  Alarm.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import AudioToolbox
import Foundation
import UIKit
import UserNotifications

func getPermission() {
  UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
    granted, error in
    if granted {
      print("Authorization granted")
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    } else {
      print("Authorization not granted")
    }
  }
}

func createManyNotification() {
  createNotification(timeInterval: 3)
  createNotification(timeInterval: 4)
  createNotification(timeInterval: 5)
  createNotification(timeInterval: 6)
  createNotification(timeInterval: 7)
}
func createNotification(timeInterval: TimeInterval = 5) {
  let content = UNMutableNotificationContent()
  content.title = "Alarm"
  content.body = "Wake up!"
  content.sound = .default
  // content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "silence_30s.caf"))
  content.categoryIdentifier = "alarm"
  // content.userInfo = ["vibration": true]
  content.interruptionLevel = .active

  // AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }

  let date = Date().addingTimeInterval(timeInterval)  // 5 seconds
  let trigger = UNTimeIntervalNotificationTrigger(
    timeInterval: date.timeIntervalSinceNow, repeats: false)
  // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
  let request = UNNotificationRequest(
    identifier: UUID().uuidString, content: content, trigger: trigger)

  let center = UNUserNotificationCenter.current()
  // center.removeAllPendingNotificationRequests()
  // center.removeAllDeliveredNotifications()
  // center.removeDeliveredNotifications(withIdentifiers: ["your notification identifier"])
  center.add(request)
  // center.delegate = self
}

func userNotificationCenter(
  _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
  withCompletionHandler completionHandler: @escaping () -> Void
) {
  let userInfo = response.notification.request.content.userInfo
  if let vibration = userInfo["vibration"] as? Bool, vibration {
    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
      // loop the vibration sound until the user interacts with the notification
      AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
    }
  }
  completionHandler()
}
