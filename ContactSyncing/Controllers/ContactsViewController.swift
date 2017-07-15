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

	@IBOutlet fileprivate var settingsBarButtonItem: UIBarButtonItem!
	@IBOutlet fileprivate var contingencyView: UIView!
	@IBOutlet fileprivate var contingencyViewTapGestureRecognizer: UITapGestureRecognizer!
	@IBOutlet fileprivate var contactsPermissionNotGrantedView: UIView!
	@IBOutlet fileprivate var contactsPermissionNotGrantedTapGestureRecognizer: UITapGestureRecognizer!

	var nonRefresingTitle: String {
		let newContactsCount = UInt(self.tableViewController.syncedPhoneContacts.value.filter { !$0.hasBeenSeen }.count)
		if newContactsCount == 0 {
			return ContactsViewController.noNewContactString
		} else {
			return "\(newContactsCount) \(ContactsViewController.newContactString)\(newContactsCount > 1 ? "s" : "")"
		}
	}

	var tableViewController: ContactsTableViewController!
	private let disposable = CompositeDisposable()

	override func viewDidLoad() {
		super.viewDidLoad()

		ContactFetcher.shared.requestContactsPermission()

		self.reactive.title <~ self.tableViewController.isSyncing.map { $0 ? "Refreshing Contacts" : self.nonRefresingTitle }

		self.disposable += self.contingencyView.reactive.animatedAlpha <~ SignalProducer.combineLatest(
			self.tableViewController.syncedPhoneContacts.producer.map { !$0.isEmpty },
			self.tableViewController.isSyncing.producer,
			ContactFetcher.shared.isContactsPermissionGranted.producer
		).map { $0 || $1 || !$2 ? 0.0 : 1.0 }

		self.disposable += self.contingencyViewTapGestureRecognizer.reactive.isEnabled <~ SignalProducer.combineLatest(
			self.tableViewController.syncedPhoneContacts.producer.map { $0.isEmpty },
			ContactFetcher.shared.isContactsPermissionGranted.producer
		).map { $0 && $1 }

		self.disposable += self.contactsPermissionNotGrantedTapGestureRecognizer.reactive.isEnabled <~ ContactFetcher.shared.isContactsPermissionGranted.negate()
		self.disposable += self.contactsPermissionNotGrantedView.reactive.animatedAlpha <~ ContactFetcher.shared.isContactsPermissionGranted.map { $0 ? 0.0 : 1.0 }
		self.disposable += self.settingsBarButtonItem.reactive.isEnabled <~ ContactFetcher.shared.isContactsPermissionGranted.producer

		DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
			PushNotificationCoordinator.scheduleLocalNotifications()
		}
	}

	deinit {
		self.disposable.dispose()
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
			self.tableViewController.syncContactsProgrammatically()
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

	@IBAction func contingencyViewTapped(_ sender: Any) {
		self.tableViewController.syncContactsProgrammatically()
	}

	@IBAction func contactsPemissionNotGrantedViewTapped(_ sender: Any) {
		guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
			return
		}
		UIApplication.shared.openURL(settingsUrl)
	}
}
