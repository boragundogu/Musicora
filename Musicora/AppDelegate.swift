//
//  AppDelegate.swift
//  Musicora
//
//  Created by Bora Gündoğu on 13.03.2025.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        _ = MusicManager.shared

        window = UIWindow(frame: UIScreen.main.bounds)
        let splashViewController = SplashViewController()
        let navController = UINavigationController(rootViewController: splashViewController)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        Localizer.swizzleMainBundle()

        return true
    }
}
