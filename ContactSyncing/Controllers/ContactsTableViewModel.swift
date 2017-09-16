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

final class ContactsTableViewModel: NSObject {
	var dataSource = MutableProperty<DataSource>(EmptyDataSource())
	private let disposable = CompositeDisposable()

	let syncedPhoneContacts = MutableProperty<Set<PhoneContact>>([])
	let isSyncing = MutableProperty(false)

	private let syncingWaitForMinimumDelayAction = Action<Void, Void, NoError> {
		return SignalProducer { observer, disposable in
			disposable += schedule(after: 1.0) {
				observer.send(value: ())
				observer.sendCompleted()
			}
		}
	}

	deinit {
		self.disposable.dispose()
	}

	override init() {
		super.init()

		self.disposable += self.isSyncing <~ SignalProducer.combineLatest(
			ContactFetcher.shared.syncContactsAction.isExecuting.producer,
			self.syncingWaitForMinimumDelayAction.isExecuting.producer
		).map { $0 || $1 }
	}

	func syncContacts() {
		self.syncingWaitForMinimumDelayAction.apply().start()
		self.disposable += ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			if let syncedContacts = result.value {
				self?.syncedPhoneContacts.value.removeAll()
				syncedContacts.forEach { self?.syncedPhoneContacts.value.insert($0) }
				self?.updateDataSource()
			}
		}
	}

	func removeAllContacts() {
		do {
			try RealmManager.shared.realm.write {
				RealmManager.shared.realm.delete(RealmManager.shared.realm.objects(PhoneContact.self))
				self.syncedPhoneContacts.value.removeAll()
				self.updateDataSource()
			}
		} catch {
			print("Entrance View Model: could not remove all contacts")
		}
	}

	fileprivate func updateDataSource() {
		let existingContacts = self.syncedPhoneContacts.value.filter { !$0.hasBeenSeen }.sorted { $0.0.dateAdded < $0.1.dateAdded }
		var sections: [DataSourceSection<ContactTableViewCellModel>] = existingContacts
			.splitBetween {
				return floor($0.0.dateAdded.timeIntervalSince1970 / (60.0 * 60.0 * 24.0)) != floor($0.1.dateAdded.timeIntervalSince1970 / (60.0 * 60.0 * 24.0))
			}.map { contacts in
				return DataSourceSection(items: contacts.map { ContactTableViewCellModel(contact: $0) })
		}

		let newContacts = self.syncedPhoneContacts.value.filter { $0.hasBeenSeen }
		if !newContacts.isEmpty {
			sections.append(DataSourceSection(items: newContacts.map { ContactTableViewCellModel(contact: $0) }))
		}
		self.dataSource.value = StaticDataSource(sections: sections)
	}
}
