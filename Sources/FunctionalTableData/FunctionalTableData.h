//
//  FunctionalTableData.h
//  FunctionalTableData
//
//  Created by Geoffrey Foster on 2019-11-05.
//  Copyright © 2019 Shopify. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for FunctionalTableData.
FOUNDATION_EXPORT double FunctionalTableDataVersionNumber;

//! Project version string for FunctionalTableData.
FOUNDATION_EXPORT const unsigned char FunctionalTableDataVersionString[];

NSException* __nullable catchExceptionOfKind(Class __nonnull type, void (^ __nonnull inBlock)(void)) {
	@try {
		inBlock();
	} @catch (NSException *exception) {
		if ([exception isKindOfClass:type]) {
			return exception;
		} else {
			@throw;
		}
	}
	return nil;
}
