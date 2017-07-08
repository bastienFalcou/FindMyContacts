//
//  FoundationExtensions.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/4/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation

extension Date {
	var readable: String {
		let today = Date()
		switch floor(self.timeIntervalSince1970 / (60 * 60 * 24)) - floor(today.timeIntervalSince1970 / (60 * 60 * 24)) {
		case 0:
			return "Today"
		case 1:
			return "Yesterday"
		default:
			let formatter = DateFormatter()
			formatter.dateStyle = .long
			formatter.timeStyle = .none
			return formatter.string(from: self)
		}
	}
}
