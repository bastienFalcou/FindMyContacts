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
		self.viewModel.syncContacts()
	}

	@IBAction func removeAllContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.removeAllContacts()
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
