//
//  RealmManager.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmManager: NSObject {
	private static let applicationGroupIdentifier = "group.bastienFalcou.FindMyContacts"

	static let shared = RealmManager()

	let realm: Realm

	override init() {
		guard Thread.isMainThread else {
			fatalError("Realm Manager: main Realm was created from background Thread")
		}

		if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: RealmManager.applicationGroupIdentifier) {
			let realmURL = container.absoluteURL.appendingPathComponent("default.realm")
			let config = Realm.Configuration(fileURL: realmURL)
			Realm.Configuration.defaultConfiguration = config
		}

		self.realm = try! Realm()
	}

	func performInBackground(_ backgroundAction: @escaping (_ backgroundRealm: Realm) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let backgroundRealm = try! Realm()
			backgroundAction(backgroundRealm)
		}
	}
}
