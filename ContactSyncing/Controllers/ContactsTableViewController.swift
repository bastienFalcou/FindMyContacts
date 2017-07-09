//
//  ViewController.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import ReactiveSwift
import DataSource

final class ContactsTableViewController: UITableViewController {
	fileprivate let viewModel = ContactsTableViewModel()
	fileprivate let tableDataSource = TableViewDataSource()

	var syncedPhoneContacts: MutableProperty<Set<PhoneContact>> {
		return self.viewModel.syncedPhoneContacts
	}
	var isSyncing: MutableProperty<Bool> {
		return self.viewModel.isSyncing
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableDataSource.reuseIdentifierForItem = { _ in
			return ContactTableViewCellModel.reuseIdentifier
		}

		self.tableView.dataSource = self.tableDataSource
		self.tableView.delegate = self

		self.tableDataSource.tableView = self.tableView
		self.tableDataSource.dataSource.innerDataSource <~ self.viewModel.dataSource

		self.reactive.isRefreshing <~ self.viewModel.isSyncing.skipRepeats()

		self.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)

		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)

		self.viewModel.syncContacts()
	}

	func syncContacts() {
		self.viewModel.syncContacts()
	}
	func removeAllContacts() {
		self.viewModel.removeAllContacts()
	}

	@objc fileprivate func handleRefresh(refreshControl: UIRefreshControl) {
		self.viewModel.syncContacts()
	}
	@objc fileprivate func applicationWillEnterForeground(notification: Foundation.Notification) {
		if ContactFetcher.shared.isContactsPermissionGranted.value {
			self.forceDisplayRefreshControl()
			self.viewModel.syncContacts()
		}
	}
}

extension ContactsTableViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let firstViewModel = self.tableDataSource.dataSource.item(at: IndexPath(row: 0, section: section)) as! ContactTableViewCellModel
		let headerView = ContactTableHeaderView()
		let text = firstViewModel.contact.hasBeenSeen ? firstViewModel.contact.dateAdded.readable : "new"
		headerView.titleLabel?.text = text.uppercased()
		return headerView
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28.0
	}
}
