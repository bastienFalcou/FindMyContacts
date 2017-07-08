//
//  ContactTableHeaderViewModel.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/4/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation

struct ContactTableHeaderViewModel {
	static var reuseIdentifier: String {
		return String(describing: ContactTableHeaderView.self)
	}

	var title: String
}
