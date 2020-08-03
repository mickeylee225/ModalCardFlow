//
//  AppDelegate.swift
//  ModalCardFlowExample
//
//  Created by Mickey Lee on 03/08/2020.
//  Copyright © 2020 Mickey Lee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = LandingViewController(nibName: String(describing: LandingViewController.self), bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        window!.rootViewController = nav
        window!.makeKeyAndVisible()
        return true
    }
}

