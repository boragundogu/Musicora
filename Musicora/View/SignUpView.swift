//
//  SignUpView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.07.2025.
//

import UIKit
import SnapKit

final class SignUpView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesap Oluştur"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Müzikleri tanımaya başla."
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
    
    let nameField = CustomTextField(placeholder: "isim")
    let surnameField = CustomTextField(placeholder: "Soyisim")
    let mailField = CustomTextField(placeholder: "Mail", keyboardType: .emailAddress)
    let passwordField = CustomTextField(placeholder: "Şifre", isSecure: true)
    let rePasswordField = CustomTextField(placeholder: "Tekrar Şifre", isSecure: true)
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
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
        addSubview(signUpButton)
        
        formStackView.addArrangedSubview(nameField)
        formStackView.addArrangedSubview(surnameField)
        formStackView.addArrangedSubview(mailField)
        formStackView.addArrangedSubview(passwordField)
        formStackView.addArrangedSubview(rePasswordField)
        
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
        
        nameField.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
            make.height.equalTo(55)
        }
    }
}
