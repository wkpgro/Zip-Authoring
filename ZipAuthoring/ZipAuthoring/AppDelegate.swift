//
//  AppDelegate.swift
//  ZipAuthoring
//
//  Created by xr on 5/2/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit
import AWSCore
import AWSMobileClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dd = AWSMobileClient.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation:annotation)
    
        return dd
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}

