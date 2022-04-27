//
//  AppDelegate.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let vc = ViewController()

        window = UIWindow()

        window?.rootViewController = vc
        window?.makeKeyAndVisible()

        return true
    }
}

