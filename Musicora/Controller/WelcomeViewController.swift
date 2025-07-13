//
//  ViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 13.03.2025.
//

import UIKit

final class WelcomeViewController: UIViewController {
    
    private var welcomeView: WelcomeView!
    
    override func loadView() {
        welcomeView = WelcomeView()
        view = welcomeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        
        navigationItem.hidesBackButton = true
    }
    
    private func setupTargets() {
        welcomeView.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        welcomeView.signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    @objc private func didTapSignIn() {
        let signInVC = SignInViewController()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    @objc private func didTapSignUp() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}
