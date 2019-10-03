//
//  ObjCExceptionRethrower.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-07-28.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation
import CwlCatchException

extension NSException {
	public static func catchAndRethrow(_ block: @escaping () -> Void, failure: (_ exception: NSException) -> Void) {
		let exception = NSException.catchException {
			block()
			return
		}
				
		if let exception = exception {
			failure(exception)
			exception.raise()
		}
	}
	
	public static func catchAndHandle(_ block: @escaping () -> Void, failure: (_ exception: NSException) -> Void) {
		let exception = NSException.catchException {
			block()
			return
		}
				
		if let exception = exception {
			failure(exception)
		}
	}
}
