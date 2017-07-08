//
//  AppDelegate.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		return true
	}

	func applicationWillTerminate(_ application: UIApplication) {
		do {
			try RealmManager.shared.realm.write {
				RealmManager.shared.realm.objects(PhoneContact.self).forEach { $0.hasBeenSeen = true }
			}
		} catch {
			print("Failed to mark all contacts as seen when closing application")
		}
	}
}
