//
//  WelcomeView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.07.2025.
//

import UIKit
import SnapKit

final class WelcomeView: UIView {
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Musicora'ya Hoş Geldin"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Müzik dünyasını ve zevklerini keşfet."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(.systemPurple, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPurple.cgColor
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
        
        addSubview(contentStackView)
        addSubview(buttonStackView)
        
        contentStackView.addArrangedSubview(logoImageView)
        contentStackView.addArrangedSubview(welcomeLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        
        buttonStackView.addArrangedSubview(signUpButton)
        buttonStackView.addArrangedSubview(signInButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(60)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(80)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(40)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
    }
}
