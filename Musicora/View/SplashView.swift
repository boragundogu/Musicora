//
//  SplashView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 29.03.2025.
//

import UIKit
import SnapKit

final class SplashView: UIView {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var loadingBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 0.0
        progressBar.tintColor = .blue
        return progressBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(named: "bg") ?? .white
        addSubview(logoImageView)
        addSubview(loadingBar)
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
        loadingBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.width.equalTo(200)
        }
    }
    
    func updateProgress(_ progress: Float) {
        loadingBar.progress = progress
    }
}
