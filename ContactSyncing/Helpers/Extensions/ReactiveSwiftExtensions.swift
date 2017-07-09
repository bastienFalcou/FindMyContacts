//
//  ReactiveSwiftExtensions.swift
//  FindMyContacts
//
//  Created by Bastien Falcou on 7/9/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@discardableResult
func schedule(after timeInterval: TimeInterval, action: @escaping () -> Void) -> Disposable? {
	let scheduler = QueueScheduler.main
	let date = scheduler.currentDate.addingTimeInterval(timeInterval)
	return scheduler.schedule(after: date, action: action)
}
