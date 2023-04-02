//
//  Alarm.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import Foundation
import UserNotifications
import AudioToolbox

func getPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Authorization granted")
        } else {
            print("Authorization not granted")
        }
    }
}

func createNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Wake up!"
    content.sound = .default
    content.categoryIdentifier = "alarm"
    content.userInfo = ["vibration": true]

    // AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }

    let date = Date().addingTimeInterval(60) // the alarm will sound in 60 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
    let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)

    let center = UNUserNotificationCenter.current()
    center.add(request)
    // center.delegate = self
    center.removeAllPendingNotificationRequests()
}

func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if let vibration = userInfo["vibration"] as? Bool, vibration {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
            // loop the vibration sound until the user interacts with the notification
            AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
        }
    }
    completionHandler()
}
