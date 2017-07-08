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

class ContactTableHeaderView: TableViewHeaderFooterView {
	@IBOutlet private var titleLabel: UILabel?

	override func awakeFromNib() {
		super.awakeFromNib()

		self.viewModel.producer
			.map { $0 as? ContactTableHeaderViewModel }
			.skipNil()
			.startWithValues { [weak self] in
				self?.titleLabel?.text = $0.title
		}
	}
}
