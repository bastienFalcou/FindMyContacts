//
//  UIKitExtensions.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/9/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit

extension UITableViewController {
	func forceDisplayRefreshControl() {
		// workaround iOS known bug with table view controller not showing refresh control if action triggered
		// programatically, reference:
		// https://stackoverflow.com/questions/14718850/uirefreshcontrol-beginrefreshing-not-working-when-uitableviewcontroller-is-ins
		let y = self.tableView.contentOffset.y - (self.refreshControl?.frame.size.height ?? 0.0)
		self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: y), animated: true)
	}
}
