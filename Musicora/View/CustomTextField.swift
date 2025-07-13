//
//  CustomTextField.swift
//  Musicora
//
//  Created by Bora Gündoğu on 23.03.2025.
//

import UIKit
import SnapKit

final class CustomTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    init(placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)
        
        self.isSecureTextEntry = isSecure
        self.keyboardType = keyboardType
        
        backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.2)
        textColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        leftViewMode = .always
        
        autocorrectionType = .no
        autocapitalizationType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
