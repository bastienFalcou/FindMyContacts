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

final class EntranceViewController: UITableViewController {
	static let noNewContactString = "No New Contact"
	static let newContactString = "New Contact"

	var nonRefresingTitle: String {
		let newContactsCount = UInt(self.viewModel.syncedPhoneContacts.value.filter { !$0.hasBeenSeen }.count)
		if newContactsCount == 0 {
			return EntranceViewController.noNewContactString
		} else {
			return "\(newContactsCount) \(EntranceViewController.newContactString)\(newContactsCount > 1 ? "s" : "")"
		}
	}

	let viewModel = EntranceViewModel()
	let tableDataSource = TableViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()

		ContactFetcher.shared.requestContactsPermission()

		self.tableDataSource.reuseIdentifierForItem = { _ in
			return ContactTableViewCellModel.reuseIdentifier
		}

		self.tableView.dataSource = self.tableDataSource
		self.tableView.delegate = self

		self.tableDataSource.tableView = self.tableView
		self.tableDataSource.dataSource.innerDataSource <~ self.viewModel.dataSource

		self.reactive.isRefreshing <~ self.viewModel.isSyncing.skipRepeats()
		self.reactive.title <~ self.viewModel.isSyncing.map { $0 ? "Refreshing Contacts" : self.nonRefresingTitle }

		self.refreshControl?.addTarget(self, action: #selector(EntranceViewController.handleRefresh(refreshControl:)), for: .valueChanged)

		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)

		self.viewModel.syncContacts()
	}

	fileprivate func removeAllContacts() {
		let alertController = UIAlertController(title: "Remove All", message: "This will reinit all of your contacts, do you really want to continue?", preferredStyle: .alert)

		let okAction = UIAlertAction(title: "Remove All", style: .destructive) { _ in
			self.viewModel.removeAllContacts()
			self.title = EntranceViewController.noNewContactString
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

		alertController.addAction(okAction)
		alertController.addAction(cancelAction)

		self.present(alertController, animated: true, completion: nil)
	}

	@IBAction func settingsBarButtonItemTapped(_ sender: Any) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let markAsReadAction = UIAlertAction(title: "Mark all as Seen", style: .default) { _ in
			PhoneContact.markAsAllSeen()
			self.viewModel.syncContacts()
		}
		let deleteAction = UIAlertAction(title: "Remove all Contacts", style: .destructive) { _ in
			self.removeAllContacts()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
			alertController.dismiss(animated: true, completion: nil)
		}
		alertController.addAction(markAsReadAction)
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		self.present(alertController, animated: true, completion: nil)
	}

	@objc fileprivate func handleRefresh(refreshControl: UIRefreshControl) {
		self.viewModel.syncContacts()
	}

	@objc fileprivate func applicationWillEnterForeground(notification: Foundation.Notification) {
		self.forceDisplayRefreshControl()
		self.viewModel.syncContacts()
	}
}

extension EntranceViewController {
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
