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

		self.refreshControl?.addTarget(self, action: #selector(EntranceViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)

		self.viewModel.isSyncing.producer.startWithValues { [weak self] isSyncing in
			if isSyncing {
				self?.refreshControl?.beginRefreshing()
			} else {
				self?.refreshControl?.endRefreshing()
			}
		}

		self.viewModel.syncContacts()
	}

	@IBAction func removeAllContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.removeAllContacts()
	}

	@IBAction func settingsBarButtonItemTapped(_ sender: Any) {
		let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let deleteAction = UIAlertAction(title: "Delete All History", style: .destructive) { alert in
			self.viewModel.removeAllContacts()
		}
		optionMenu.addAction(deleteAction)
		self.present(optionMenu, animated: true, completion: nil)
	}

	@objc fileprivate func handleRefresh(refreshControl: UIRefreshControl) {
		self.viewModel.syncContacts()
	}
}

extension EntranceViewController {
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let firstViewModel = self.tableDataSource.dataSource.item(at: IndexPath(row: 0, section: section)) as! ContactTableViewCellModel
		let headerView = ContactTableHeaderView()
		headerView.titleLabel?.text = firstViewModel.contact.dateAdded.readable.uppercased()
		return headerView
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28.0
	}
}
