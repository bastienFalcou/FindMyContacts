//
//  TodayViewModel.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/15/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import ReactiveSwift

final class TodayViewModel: NSObject {
	var syncedPhoneContacts = MutableProperty<Set<PhoneContact>>([])

	override init() {
		super.init()

		ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			if let syncedContacts = result.value {
				self?.syncedPhoneContacts.value.removeAll() // TODO: Test if needed given that set
				syncedContacts.forEach { self?.syncedPhoneContacts.value.insert($0) }
				//self?.updateDataSource()
			}
		}
	}
}
