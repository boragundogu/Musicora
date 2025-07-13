//
//  ChangePasswordView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 01.07.2025.
//

import UIKit
import SnapKit

final class ChangePasswordView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Şifre Değiştir"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Güvenliğiniz için yeni bir şifre belirleyin."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let currentPasswordField = CustomTextField(placeholder: "Mevcut Şifre", isSecure: true)
    let newPasswordField = CustomTextField(placeholder: "Yeni Şifre", isSecure: true)
    let confirmPasswordField = CustomTextField(placeholder: "Yeni Şifre Tekrar", isSecure: true)
    
    private let passwordRequirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Şifreniz en az 8 karakter uzunluğunda olmalı, büyük harf, küçük harf ve rakam içermelidir."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Şifreyi Değiştir", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "bg")
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(formStackView)
        addSubview(passwordRequirementsLabel)
        addSubview(changePasswordButton)
        
        formStackView.addArrangedSubview(currentPasswordField)
        formStackView.addArrangedSubview(newPasswordField)
        formStackView.addArrangedSubview(confirmPasswordField)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(30)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        formStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
        }
        
        [currentPasswordField, newPasswordField, confirmPasswordField].forEach { field in
            field.snp.makeConstraints { make in
                make.height.equalTo(55)
            }
        }
        
        passwordRequirementsLabel.snp.makeConstraints { make in
            make.top.equalTo(formStackView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(formStackView)
        }
        
        changePasswordButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(55)
        }
    }
}

struct PasswordValidator {
    
    enum ValidationError: LocalizedError {
        case tooShort
        case noUppercase
        case noLowercase
        case noDigit
        case passwordsDoNotMatch
        case currentPasswordIncorrect
        
        var errorDescription: String? {
            switch self {
            case .tooShort:
                return "Şifre en az 8 karakter olmalıdır"
            case .noUppercase:
                return "Şifre en az bir büyük harf içermelidir"
            case .noLowercase:
                return "Şifre en az bir küçük harf içermelidir"
            case .noDigit:
                return "Şifre en az bir rakam içermelidir"
            case .passwordsDoNotMatch:
                return "Şifreler eşleşmiyor"
            case .currentPasswordIncorrect:
                return "Mevcut şifre yanlış"
            }
        }
    }
    
    static func validate(password: String) -> ValidationError? {
        if password.count < 8 {
            return .tooShort
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            return .noUppercase
        }
        
        if !password.contains(where: { $0.isLowercase }) {
            return .noLowercase
        }
        
        if !password.contains(where: { $0.isNumber }) {
            return .noDigit
        }
        
        return nil
    }
    
    static func validatePasswordChange(currentPassword: String, newPassword: String, confirmPassword: String, savedPassword: String) -> ValidationError? {
        
        if currentPassword != savedPassword {
            return .currentPasswordIncorrect
        }
        
        if let error = validate(password: newPassword) {
            return error
        }
        
        if newPassword != confirmPassword {
            return .passwordsDoNotMatch
        }
        
        return nil
    }
}
