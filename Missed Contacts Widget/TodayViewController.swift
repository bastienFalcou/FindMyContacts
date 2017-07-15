//
//  TodayViewController.swift
//  Missed Contacts Widget
//
//  Created by Bastien Falcou on 7/15/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import NotificationCenter
import EthanolContacts
import ReactiveSwift
import Result

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet private var newContactsLabel: UILabel!
	@IBOutlet private var tableView: UITableView!

	private let viewModel = TodayViewModel()

	override func viewDidLoad() {
		super.viewDidLoad()

		if !ContactFetcher.shared.isContactsPermissionGranted.value {
			self.newContactsLabel.text = "Access to Contacts not granted"
		}

		self.newContactsLabel.reactive.text <~ self.viewModel.syncedPhoneContacts.producer.map {
			$0.isEmpty ? "No New Contact" : "\($0.count) New Contact\($0.count > 1 ? "s" : "")"
		}
	}

	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			switch result {
			case .success(let syncedContacts):
				self?.viewModel.syncedPhoneContacts.value.removeAll() // TODO: Test if needed given that set
				syncedContacts.forEach { self?.viewModel.syncedPhoneContacts.value.insert($0) }

				if self?.viewModel.syncedPhoneContacts.value.filter({ $0.hasBeenSeen }).isEmpty ?? true {
					completionHandler(.noData)
				} else {
					completionHandler(.newData)
				}
			case .failure:
				completionHandler(.failed)
			}

			if let syncedContacts = result.value {
				self?.viewModel.syncedPhoneContacts.value.removeAll() // TODO: Test if needed given that set
				syncedContacts.forEach { self?.viewModel.syncedPhoneContacts.value.insert($0) }
			}
		}
	}
}
