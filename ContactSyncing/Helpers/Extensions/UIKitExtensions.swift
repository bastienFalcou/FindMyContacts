//
//  UIKitExtensions.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/9/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit

extension UITableViewController {
	func forceDisplayRefreshControl(delay: Bool = true) {
		// Workaround iOS known bug with table view controller not showing refresh control if action triggered
		// programatically. In addition, the table view controller layout passes tend to cancel this override
		// of the content offset, forcing us to have to wait for layout to have completed before changing it. 
		// Reference: https://stackoverflow.com/questions/14718850/uirefreshcontrol-beginrefreshing-not-working-when-uitableviewcontroller-is-ins
		DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 0.05 : 0.0)) {
			let y = self.tableView.contentOffset.y - (self.refreshControl?.frame.size.height ?? 0.0)
			self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: y), animated: true)
		}
	}
}
