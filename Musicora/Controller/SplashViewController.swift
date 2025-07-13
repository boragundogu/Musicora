//
//  SplashViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 15.03.2025.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    
    private let splashView = SplashView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(splashView)

        splashView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        animateLoadingBar()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigateToNextScreen()
        }
    }
    
    private func animateLoadingBar() {
        var progress: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.1
            self.splashView.updateProgress(progress)
            if progress >= 1.0 {
                timer.invalidate()
                self.navigateToNextScreen()
            }
        }
    }
    
    private func navigateToNextScreen() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let nextViewController = isLoggedIn ? MainTabBarController() : WelcomeViewController()
        navigationController?.setViewControllers([nextViewController], animated: true)
    }
}
