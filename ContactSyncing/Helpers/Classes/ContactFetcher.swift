//
//  PhoneContactsFetcher.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift
import EthanolContacts
import ReactiveSwift
import Contacts

final class ContactFetcher: NSObject {
	static var shared = ContactFetcher()

	private let phoneContactFetcher = PhoneContactFetcher()
	var syncContactsAction: Action<Void, [PhoneContact], NSError>!

	let isContactsPermissionGranted = MutableProperty(false)

	override init() {
		super.init()
		self.syncContactsAction = Action(self.syncLocalAddressBook)
	}

	func requestContactsPermission() {
		self.phoneContactFetcher.authorize(success: {
			self.updateAuthorizationStatusIfNeeded()
		}) { _ in
			self.updateAuthorizationStatusIfNeeded()
		}
	}

	// PRAGMA: - private

	fileprivate func syncLocalAddressBook() -> SignalProducer<[PhoneContact], NSError> {
		return SignalProducer { sink, disposable in
			self.phoneContactFetcher.fetchContacts(for: [.GivenName, .FamilyName, .Phone], success: { contacts in
				RealmManager.shared.performInBackground { backgroundRealm in
					var contactEntities = Set<PhoneContact>()
					backgroundRealm.beginWrite()

					for contact in contacts where contact.phone != nil && !contact.phone!.isEmpty {
						let contactEntity = PhoneContact.uniqueObject(for: contact.identifier, in: backgroundRealm)
						contactEntity.phoneNumber = contact.phone!.first!
						contactEntity.username = contact.familyName.isEmpty ? "\(contact.givenName)" : "\(contact.givenName) \(contact.familyName)"
						contactEntities.insert(contactEntity)
					}

					do {
						backgroundRealm.add(contactEntities)
						try backgroundRealm.commitWrite()
						try PhoneContact.substractObsoleteLocalContacts(with: Array(contactEntities), realm: backgroundRealm)

						DispatchQueue.main.async {
							RealmManager.shared.realm.refresh()
							sink.send(value: Array(RealmManager.shared.realm.objects(PhoneContact.self)))
							sink.sendCompleted()
						}
					} catch {
						print("Contacts: failed to save synced contacts: \(error)")
						sink.send(error: error as NSError)
					}
				}
			}) { error in
				let error = error != nil ? error! as NSError : NSError(domain: "bastienFalcou.FindMyContacts.ContactFetcher.", code: 0, userInfo: nil)
				print("Contacts: failed to save synced contacts: \(error.localizedDescription)")
				sink.send(error: error)
			}
		}
	}

	func updateAuthorizationStatusIfNeeded() {
		let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
		self.isContactsPermissionGranted.value = authorizationStatus == .authorized
	}
}
