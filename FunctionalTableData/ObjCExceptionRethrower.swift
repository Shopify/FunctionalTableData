//
//  ObjCExceptionRethrower.swift
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2016-07-28.
//  Copyright © 2016 Shopify. All rights reserved.
//

import Foundation

extension NSException {
	public static func catchAndRethrow(_ block: () -> Void, failure: (_ exception: NSException) -> Void) {
		catchAndRethrowException(block, failure)
	}
}
