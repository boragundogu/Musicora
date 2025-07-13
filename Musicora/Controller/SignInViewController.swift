//
//  SignInVC.swift
//  Musicora
//
//  Created by Bora Gündoğu on 15.03.2025.
//

import UIKit
import SnapKit

final class SignInViewController: UIViewController {
    
    private let signInView = SignInView()

    override func loadView() {
        view = signInView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        signInView.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    @objc private func didTapSignIn() {
        guard let mail = signInView.mailField.text, !mail.isEmpty,
              let password = signInView.passwordField.text, !password.isEmpty else {
            showAlert(message: "Mail ve şifre alanı dolu olmalı!")
            return
        }
    
        guard let savedUser = User(from: UserDefaults.standard) else {
            showAlert(message: "Kayıtlı kullanıcı bulunamadı!")
            return
        }
    
        if mail == savedUser.mail && password == savedUser.password {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            navigateToHome()
        } else {
            showAlert(message: "Mail veya şifre hatalı!")
        }
    }
    
    private func navigateToHome() {
        let mainTabBarController = MainTabBarController()
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
