//
//  ContactTableHeaderView.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/4/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift
import EthanolUIComponents

class ContactTableHeaderView: ETHNibView {
	@IBOutlet private(set) var titleLabel: UILabel?

	override func nibName() -> String {
		return "ContactTableHeaderView"
	}
}
