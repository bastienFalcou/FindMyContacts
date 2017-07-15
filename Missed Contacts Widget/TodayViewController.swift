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
import DataSource

class TodayViewController: UIViewController {
	@IBOutlet private var newContactsLabel: UILabel!
	@IBOutlet private var tableView: UITableView!

	fileprivate let viewModel = TodayViewModel()
	fileprivate let tableDataSource = TableViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOSApplicationExtension 10.0, *) {
			self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			// Fallback on earlier versions
		}

		if !ContactFetcher.shared.isContactsPermissionGranted.value {
			self.newContactsLabel.text = "Access to Contacts not granted"
		}

		self.newContactsLabel.reactive.text <~ self.viewModel.syncedPhoneContacts.producer.map {
			$0.isEmpty ? "No New Contact" : "\($0.count) New Contact\($0.count > 1 ? "s" : "")"
		}

		self.tableDataSource.reuseIdentifierForItem = { _ in
			return ContactTableViewCellModel.reuseIdentifier
		}

		self.tableView.dataSource = self.tableDataSource

		self.tableDataSource.tableView = self.tableView
		self.tableDataSource.dataSource.innerDataSource <~ self.viewModel.dataSource
	}
}

extension TodayViewController: NCWidgetProviding {
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			switch result {
			case .success(let syncedContacts):
				self?.viewModel.syncedPhoneContacts.value.removeAll() // TODO: Test if needed given that set
				syncedContacts.forEach { self?.viewModel.syncedPhoneContacts.value.insert($0) }

				self?.viewModel.updateDataSource()

				if self?.viewModel.syncedPhoneContacts.value.filter({ !$0.hasBeenSeen }).isEmpty ?? true {
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

	@available(iOSApplicationExtension 10.0, *)
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if activeDisplayMode == .expanded {
			preferredContentSize = CGSize(width: 0.0, height: 330.0)
		} else if activeDisplayMode == .compact {
			preferredContentSize = maxSize
		}
	}
}

extension TodayViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let firstViewModel = self.tableDataSource.dataSource.item(at: IndexPath(row: 0, section: section)) as! ContactTableViewCellModel
		let headerView = ContactTableHeaderView()
		let text = firstViewModel.contact.hasBeenSeen ? firstViewModel.contact.dateAdded.readable : "new"

		headerView.titleLabel?.text = text.uppercased()
		headerView.contentView.backgroundColor = headerView.contentView.backgroundColor?.withAlphaComponent(0.4)

		return headerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28.0
	}
}
