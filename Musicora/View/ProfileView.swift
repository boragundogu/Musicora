//
//  ProfileView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.07.2025.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    
     let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemPurple
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
     let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    private let profileInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let iconView = UIImageView(image: UIImage(systemName: "lock.fill"))
        iconView.tintColor = .white
        
        let label = UILabel()
        label.text = NSLocalizedString("change_password", comment: "")
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = .lightGray
        
        button.addSubview(iconView)
        button.addSubview(label)
        button.addSubview(chevronView)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(15)
            make.centerY.equalToSuperview()
        }
        
        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        return button
    }()
    
    let changeLanguageButton: UIButton = {
        let button = UIButton(type: .system)
        
        let iconView = UIImageView(image: UIImage(systemName: "globe"))
        iconView.tintColor = .white
        
        let label = UILabel()
        label.text = NSLocalizedString("language_button_title", comment: "")
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = .lightGray
        
        button.addSubview(iconView)
        button.addSubview(label)
        button.addSubview(chevronView)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(15)
            make.centerY.equalToSuperview()
        }
        
        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
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
        
        profileInfoStackView.addArrangedSubview(profileImageView)
        profileInfoStackView.addArrangedSubview(editButton)
        profileInfoStackView.addArrangedSubview(nameLabel)
        profileInfoStackView.addArrangedSubview(emailLabel)
        
        addSubview(profileInfoStackView)
        addSubview(changePasswordButton)
        addSubview(changeLanguageButton)
        addSubview(logoutButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        editButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
           
        }
        
        profileInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        changePasswordButton.snp.makeConstraints { make in
            make.top.equalTo(profileInfoStackView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(55)
        }
        
        changeLanguageButton.snp.makeConstraints { make in
            make.top.equalTo(changePasswordButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(55)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(changeLanguageButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(55)
        }
    }
    
    func configure(with user: User) {
        nameLabel.text = "\(user.name) \(user.surname)"
        emailLabel.text = user.mail
    }
}
