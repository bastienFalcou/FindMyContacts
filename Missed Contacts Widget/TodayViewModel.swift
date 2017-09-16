//
//  TodayViewModel.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/15/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import ReactiveSwift
import DataSource

final class TodayViewModel: NSObject {
	var syncedPhoneContacts = MutableProperty<Set<PhoneContact>>([])
	var dataSource = MutableProperty<DataSource>(EmptyDataSource())

	func updateDataSource() {
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
