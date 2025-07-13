//
//  SignInView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.07.2025.
//

import UIKit
import SnapKit

final class SignInView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hoşgeldin!"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Giriş yap ve müzik zevkinin tadını çıkar."
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
    
    let mailField = CustomTextField(placeholder: "Mail", keyboardType: .emailAddress)
    let passwordField = CustomTextField(placeholder: "Şifre", isSecure: true)
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
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
        addSubview(signInButton)
        
        formStackView.addArrangedSubview(mailField)
        formStackView.addArrangedSubview(passwordField)
        
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
        
        mailField.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        
        signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
            make.height.equalTo(55)
        }
    }
    
    func animateSignInButton() {
        signInButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.signInButton.transform = .identity
        })
    }
    
    func showFieldError(for field: UITextField) {
        let originalColor = field.layer.borderColor
        let originalBackgroundColor = field.backgroundColor
        
        field.layer.borderColor = UIColor.systemRed.cgColor
        field.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                field.layer.borderColor = originalColor
                field.backgroundColor = originalBackgroundColor
            }
        }
    }
}
