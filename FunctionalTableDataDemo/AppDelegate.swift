//
//  AppDelegate.swift
//  FunctionalTableDataDemo
//
//  Created by Kevin Barnes on 2018-04-20.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		Separator.appearance().backgroundColor = UIColor.lightGray
		UIButton.appearance().setTitleColor(.blue, for: .normal)
		UIButton.appearance().setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
		
		return true
	}
	
}
