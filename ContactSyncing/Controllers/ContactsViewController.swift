//
//  ContactsViewController.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/9/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import ReactiveSwift
import DataSource

final class ContactsViewController: UIViewController {
	static let contactsTableViewControllerSegueIdentifier = "ContactsTableViewControllerSegueIdentifier"

	static let noNewContactString = "No New Contact"
	static let newContactString = "New Contact"

	var nonRefresingTitle: String {
		let newContactsCount = UInt(self.tableViewController.syncedPhoneContacts.value.filter { !$0.hasBeenSeen }.count)
		if newContactsCount == 0 {
			return ContactsViewController.noNewContactString
		} else {
			return "\(newContactsCount) \(ContactsViewController.newContactString)\(newContactsCount > 1 ? "s" : "")"
		}
	}

	var tableViewController: ContactsTableViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		ContactFetcher.shared.requestContactsPermission()

		self.reactive.title <~ self.tableViewController.isSyncing.map { $0 ? "Refreshing Contacts" : self.nonRefresingTitle }
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ContactsViewController.contactsTableViewControllerSegueIdentifier {
			self.tableViewController = segue.destination as! ContactsTableViewController
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}

	fileprivate func removeAllContacts() {
		let alertController = UIAlertController(title: "Remove All", message: "This will reinit all of your contacts, do you really want to continue?", preferredStyle: .alert)

		let okAction = UIAlertAction(title: "Remove All", style: .destructive) { _ in
			self.tableViewController.removeAllContacts()
			self.title = ContactsViewController.noNewContactString
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
			self.tableViewController.syncContacts()
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
}
