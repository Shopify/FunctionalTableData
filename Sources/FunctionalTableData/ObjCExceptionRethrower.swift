//
//  ObjCExceptionRethrower.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-07-28.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import CwlCatchException
#else
private func catchReturnTypeConverter<T: NSException>(_ type: T.Type, block: @escaping () -> Void) -> T? {
	return catchExceptionOfKind(type, block) as? T
}

extension NSException {
	public static func catchException(in block: @escaping () -> Void) -> Self? {
		return catchReturnTypeConverter(self, block: block)
	}
}
#endif

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
