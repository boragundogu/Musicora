//
//  LanguageSelectionViewController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 8.07.2025.
//

import UIKit

protocol LanguageSelectionDelegate: AnyObject {
    func didChangeLanguage()
}

final class LanguageSelectionViewController: UIViewController {
    
    private let languageView = LanguageSelectionView()
    private let languageManager = LanguageManager.shared
    
    weak var delegate: LanguageSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupView()
    }
    
    private func setupViewController() {
        title = "Dil Seçimi"
        view.backgroundColor = UIColor(named: "bg")
    }
    
    private func setupView() {
        view.addSubview(languageView)
        languageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            languageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            languageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            languageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            languageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        languageView.configureTableView(dataSource: self, delegate: self)
    }
}

extension LanguageSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageManager.supportedLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = languageManager.supportedLanguages[indexPath.row]
        let isSelected = language.code == languageManager.currentLanguageCode
        
        return languageView.configureCell(at: indexPath, with: language, isSelected: isSelected)
    }
}

extension LanguageSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languageManager.supportedLanguages[indexPath.row]
        
        languageManager.currentLanguageCode = selectedLanguage.code
        
        languageView.reloadData()
        
        delegate?.didChangeLanguage()
        
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 8
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}

struct Language {
    let flag: String
    let name: String
    let code: String
}

class LanguageManager {
    static let shared = LanguageManager()
    
    private init() {}
    
    let supportedLanguages: [Language] = [
        Language(flag: "🇬🇧", name: "English", code: "en"),
        Language(flag: "🇹🇷", name: "Türkçe", code: "tr"),
        Language(flag: "🇪🇸", name: "Español", code: "es")
    ]
    
    var currentLanguageCode: String {
        get {
            return UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
        }
    }
}
