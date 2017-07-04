//
//  SequenceExtensions.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/4/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation

extension Sequence {
	func splitBetween(_ areSeparated: (Iterator.Element, Iterator.Element) -> Bool) -> [[Iterator.Element]] {
		var res: [[Iterator.Element]] = []
		var chunk: [Iterator.Element] = []
		var last: Iterator.Element? = nil
		for s in self {
			if let last = last, areSeparated(last, s) {
				res.append(chunk)
				chunk = []
			}
			chunk.append(s)
			last = s
		}
		if !chunk.isEmpty {
			res.append(chunk)
		}
		return res
	}
}
