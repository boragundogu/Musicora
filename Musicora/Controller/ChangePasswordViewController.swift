//
//  ChangePasswordViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 01.07.2025.
//

import UIKit

final class ChangePasswordViewController: UIViewController {
    
    private let changePasswordView = ChangePasswordView()
    private var currentUser: User?
    
    override func loadView() {
        view = changePasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        loadCurrentUser()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
    }
    
    private func setupActions() {
        changePasswordView.changePasswordButton.addTarget(
            self,
            action: #selector(didTapChangePassword),
            for: .touchUpInside
        )
    }
    
    private func loadCurrentUser() {
        currentUser = User(from: UserDefaults.standard)
    }
    
    @objc private func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapChangePassword() {
        guard let currentPassword = changePasswordView.currentPasswordField.text, !currentPassword.isEmpty,
              let newPassword = changePasswordView.newPasswordField.text, !newPassword.isEmpty,
              let confirmPassword = changePasswordView.confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Tüm alanlar dolu olmalıdır")
            return
        }
        
        guard let user = currentUser else {
            showAlert(message: "Kullanıcı bilgileri yüklenemedi")
            return
        }
        
        if let error = PasswordValidator.validatePasswordChange(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
            savedPassword: user.password
        ) {
            showAlert(message: error.localizedDescription)
            return
        }
        
        updatePassword(newPassword: newPassword)
    }
    
    private func updatePassword(newPassword: String) {
        guard let user = currentUser else { return }
        
        let updatedUser = User(
            name: user.name,
            surname: user.surname,
            mail: user.mail,
            password: newPassword
        )
        
        updatedUser.save(to: UserDefaults.standard)
        
        showSuccessAlert()
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Başarılı",
            message: "Şifreniz başarıyla değiştirildi",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == changePasswordView.currentPasswordField {
            changePasswordView.newPasswordField.becomeFirstResponder()
        } else if textField == changePasswordView.newPasswordField {
            changePasswordView.confirmPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapChangePassword()
        }
        return true
    }
}
