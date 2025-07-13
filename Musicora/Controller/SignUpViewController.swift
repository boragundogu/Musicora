//
//  SignUpVC.swift
//  Musicora
//
//  Created by Bora Gündoğu on 15.03.2025.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    private var signUpView: SignUpView!
    
    override func loadView() {
        signUpView = SignUpView()
        view = signUpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTargets()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemPurple
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupTargets() {
        signUpView.signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    @objc private func didTapSignUp() {
        guard let name = signUpView.nameField.text, !name.isEmpty,
              let surname = signUpView.surnameField.text, !surname.isEmpty,
              let mail = signUpView.mailField.text, !mail.isEmpty,
              let password = signUpView.passwordField.text, !password.isEmpty,
              let rePassword = signUpView.rePasswordField.text, !rePassword.isEmpty else {
            showAlert(message: "Tüm alanların dolu olması gerek!")
            return
        }
        
        guard password == rePassword else {
            showAlert(message: "Şifreler aynı olmalı")
            return
        }
        
        if let passwordError = PasswordValidator.validate(password: password) {
            showAlert(message: passwordError.localizedDescription)
            return
        }
        
        let user = User(name: name, surname: surname, mail: mail, password: password)
        user.save(to: UserDefaults.standard)
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        print("Kayıt başarılı: \(name) \(surname)")
        navigateToHome()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToHome() {
        let mainTabBarController = MainTabBarController()
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
}
