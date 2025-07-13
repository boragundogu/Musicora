//
//  LanguageSelectionView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 8.07.2025.
//

import UIKit

class LanguageSelectionView: UIView {
    
    private let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "bg")
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // TableView styling
        tableView.backgroundColor = UIColor(named: "bg")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 60
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "languageCell")
    }
    
    func configureTableView(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
    }
    
    func configureCell(at indexPath: IndexPath, with language: Language, isSelected: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        
        // Cell styling
        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 4
        cell.selectionStyle = .none
        
        // Text configuration
        cell.textLabel?.text = "\(language.flag) \(language.name)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = .label
        
        // Checkmark styling
        if isSelected {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } else {
            cell.accessoryType = .none
            cell.backgroundColor = .systemBackground
        }
        
        return cell
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
