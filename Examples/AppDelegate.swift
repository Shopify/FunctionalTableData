//
//  AppDelegate.swift
//  Examples
//
//  Created by Raul Riera on 2017-08-02.
//  Copyright © 2017 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = .white
		
		let navigationController = UINavigationController(rootViewController: ExamplesViewController(style: .plain))
		window?.rootViewController = navigationController
		
		window?.makeKeyAndVisible()
		
		// Customize the appearance of the row separators
		Separator.appearance().backgroundColor = UITableView().separatorColor
		Separator.inset = 16
		
		return true
	}
}
