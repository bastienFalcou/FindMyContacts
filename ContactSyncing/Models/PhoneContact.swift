//
//  User.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

final class PhoneContact: Object {
	// Properties
	dynamic var identifier: String = ""
	dynamic var phoneNumber: String = ""
	dynamic var username: String = ""
	dynamic var dateAdded: Date = Date()
	dynamic var hasBeenSeen: Bool = false

	override static func primaryKey() -> String? {
		return "identifier"
	}

	static func allPhoneContacts(in realm: Realm = RealmManager.shared.realm) -> [PhoneContact] {
		return Array(realm.objects(PhoneContact.self))
	}

	static func substractObsoleteLocalContacts(with contacts: [PhoneContact], realm: Realm = RealmManager.shared.realm) {
		let allLocalContacts: Set<PhoneContact> = Set(realm.objects(PhoneContact.self))
		let removedContacts = allLocalContacts.subtracting(Set(contacts))

		do {
			try realm.write {
				removedContacts.forEach { realm.delete($0) }
			}
			realm.refresh()
		} catch {
			print("PhoneContact: failed to sync local database")
		}
	}

	static func markAsAllSeen() {
		do {
			try RealmManager.shared.realm.write {
				RealmManager.shared.realm.objects(PhoneContact.self).forEach { $0.hasBeenSeen = true }
			}
		} catch {
			print("PhoneContact: failed to mark all contacts as seen when closing application")
		}
	}
}
