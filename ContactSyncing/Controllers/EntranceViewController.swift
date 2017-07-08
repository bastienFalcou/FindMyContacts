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

final class EntranceViewController: UIViewController {
	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var removeAllContactsButton: UIButton!
	@IBOutlet private var syncingProgressView: UIProgressView!
	@IBOutlet private var syncingStatusLabel: UILabel!

	let viewModel = EntranceViewModel()
	let tableDataSource = TableViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()

		ContactFetcher.shared.requestContactsPermission()

		self.tableDataSource.reuseIdentifierForItem = { _, item in
			if item is ContactTableViewCellModel {
				return ContactTableViewCellModel.reuseIdentifier
			} else if item is ContactTableHeaderViewModel {
				return ContactTableHeaderViewModel.reuseIdentifier
			} else {
				fatalError("Entrance: invalid reuse identifier for cell")
			}
		}

		self.tableView.dataSource = self.tableDataSource
		self.tableView.delegate = self
		self.tableDataSource.tableView = self.tableView

		self.tableDataSource.dataSource.innerDataSource <~ self.viewModel.dataSource

		self.removeAllContactsButton.reactive.isEnabled <~ self.viewModel.isSyncing.map { !$0 }
		self.syncingStatusLabel.reactive.text <~ self.viewModel.isSyncing.map { $0 ? "Syncing in background" : "Synced" }
	}

	@IBAction func removeAllContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.removeAllContacts()
	}

	@IBAction func syncContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.syncContacts()
	}
}

extension EntranceViewController: UITableViewDelegate {

}
