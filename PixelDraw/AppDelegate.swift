//
//  AppDelegate.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/24.
//

import UIKit
import TextAttributes

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 13.0, *) {
            let apperance = UINavigationBarAppearance()
            apperance.titleTextAttributes = TextAttributes().foregroundColor(UIColor.white).dictionary
            apperance.backgroundEffect = UIBlurEffect(style: .regular)
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = apperance
            UINavigationBar.appearance().scrollEdgeAppearance = apperance
            UINavigationBar.appearance().compactAppearance = apperance
        } else {
            UINavigationBar.appearance().barStyle = .black
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().isTranslucent = true
            UINavigationBar.appearance().titleTextAttributes = TextAttributes().foregroundColor(UIColor.white).dictionary
        }


        if #available(iOS 13.0, *) {
            let apperance = UIToolbarAppearance()
            apperance.backgroundEffect = UIBlurEffect(style: .dark)
            UIToolbar.appearance().tintColor = .white
            UIToolbar.appearance().standardAppearance = apperance
            UIToolbar.appearance().compactAppearance = apperance
            if #available(iOS 15.0, *) {
                UIToolbar.appearance().scrollEdgeAppearance = apperance
            }
        } else {
            UIToolbar.appearance().barStyle = .black
            UIToolbar.appearance().isTranslucent = true
        }



        window = UIWindow()

//        let vc = ViewController()
        let vc = HomeViewController()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }
}

