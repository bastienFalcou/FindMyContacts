//
//  ViewControllerModel.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import Result
import DataSource
import ReactiveSwift

final class EntranceViewModel: NSObject {
	var dataSource = MutableProperty<DataSource>(EmptyDataSource())
	let disposable = CompositeDisposable()

	let syncedPhoneContacts = MutableProperty<Set<PhoneContact>>([])
	let isSyncing = MutableProperty(false)

	deinit {
		self.disposable.dispose()
	}

	override init() {
		super.init()

		self.disposable += self.isSyncing <~ ContactFetcher.shared.syncContactsAction.isExecuting
		self.disposable += self.syncedPhoneContacts.producer.startWithValues { [weak self] syncedPhoneContacts in
			let sections: [DataSourceSection<ContactTableViewCellModel>] = syncedPhoneContacts
				.splitBetween {
					return floor($0.0.dateAdded.timeIntervalSince1970 / (60 * 60 * 24)) != floor($0.1.dateAdded.timeIntervalSince1970 / (60 * 60 * 24))
				}.map { contacts in
					let date = contacts.first?.dateAdded
					return DataSourceSection(
						items: contacts.map {  ContactTableViewCellModel(contact: $0) },
						supplementaryItems: [UICollectionElementKindSectionHeader: ContactTableHeaderViewModel(title: date?.readable ?? "")]
					)
			}
			self?.dataSource.value = StaticDataSource(sections: sections)
		}
	}

	func syncContacts() {
		self.disposable += ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			if let syncedContacts = result.value {
				syncedContacts.forEach { self?.syncedPhoneContacts.value.insert($0) }
			}
		}
	}

	func removeAllContacts() {
		do {
			try RealmManager.shared.realm.write {
				RealmManager.shared.realm.delete(RealmManager.shared.realm.objects(PhoneContact.self))
				self.syncedPhoneContacts.value = Set(PhoneContact.allPhoneContacts())
			}
		} catch {
			print("Entrance View Model: could not remove all contacts")
		}
	}
}
