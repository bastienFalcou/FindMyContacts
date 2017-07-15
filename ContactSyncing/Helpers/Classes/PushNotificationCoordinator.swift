//
//  PushNotificationManager.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/15/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import UserNotifications

struct PushNotificationCoordinator {
	static func scheduleLocalNotifications() {
		self.removeScheduledLocalNotifications()

		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
				switch notificationSettings.authorizationStatus {
				case .notDetermined:
					self.requestAuthorization()
				case .authorized:
					self.scheduleNotifications()
				case .denied:
					print("Application Not Allowed to Display Notifications")
				}
			}
		} else {
			self.requestAuthorization()
			self.scheduleNotifications()
		}
	}

	private static func requestAuthorization() {
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
				if let error = error {
					print("Request Authorization Failed (\(error), \(error.localizedDescription))")
				}
			}
		} else {
			let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
			UIApplication.shared.registerUserNotificationSettings(settings)
		}
	}

	private static func scheduleNotifications() {
		let calendar = Calendar.current

		// weekday goes from 1 - 7, with 1 being Sunday and 7 being Saturday
		// this positions trigger time following Sunday at 2 PM
		var dateComponents = calendar.dateComponents([.weekday], from: Date())
		let advanceDays = 8 - dateComponents.weekday!

		dateComponents = calendar.dateComponents([.hour, .minute], from: Date().addingTimeInterval(TimeInterval(advanceDays) * 24.0 * 60.0))
		dateComponents.hour = 2
		dateComponents.minute = 0

		for index in 0...2 {
			if #available(iOS 10.0, *) {
				let notificationContent = UNMutableNotificationContent()
				notificationContent.title = "Went out yesterday night?"
				notificationContent.body = "It might be time to check if you have added new contacts to your phone"
				let date = calendar.date(from: dateComponents)!.addingTimeInterval(TimeInterval(index) * 2.0 * 24.0 * 60.0)
				let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
				let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
				UNUserNotificationCenter.current()
				UNUserNotificationCenter.current().add(request)
			} else {
				let notification = UILocalNotification()
				notification.fireDate = calendar.date(from: dateComponents)?.addingTimeInterval(TimeInterval(index) * 2.0 * 24.0 * 60.0)
				notification.alertTitle = "Went out yesterday night?"
				notification.alertBody = "It might be time to check if you have added new contacts to your phone"
				UIApplication.shared.scheduleLocalNotification(notification)
			}
		}
	}

	private static func removeScheduledLocalNotifications() {
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		} else {
			UIApplication.shared.cancelAllLocalNotifications()
		}
	}
}
