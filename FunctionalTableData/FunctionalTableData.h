//
//  FunctionalTableData.h
//  FunctionalTableData
//
//  Created by Raul Riera on 2017-07-31.
//  Copyright © 2017 Shopify. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for FunctionalTableData.
FOUNDATION_EXPORT double FunctionalTableDataVersionNumber;

//! Project version string for FunctionalTableData.
FOUNDATION_EXPORT const unsigned char FunctionalTableDataVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FunctionalTableData/PublicHeader.h>
NS_ASSUME_NONNULL_BEGIN

__attribute__((visibility("hidden")))
static inline void catchAndRethrowException(__attribute__((noescape)) void (^ __nonnull inBlock)(void), __attribute__((noescape)) void (^ __nonnull rethrow)(NSException *)) {
	@try {
		inBlock();
	} @catch (NSException *exception) {
		rethrow(exception);
		@throw;
	}
}

__attribute__((visibility("hidden")))
static inline void catchException(__attribute__((noescape)) void (^ __nonnull inBlock)(void), __attribute__((noescape)) void (^ __nonnull exceptionHandler)(NSException *)) {
	@try {
		inBlock();
	} @catch (NSException *exception) {
		exceptionHandler(exception);
	}
}

NS_ASSUME_NONNULL_END
