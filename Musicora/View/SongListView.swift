//
//  SongListView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 29.03.2025.
//

import UIKit
import SnapKit

final class SongListView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: "SongCell")
        tableView.separatorStyle = .none
        return tableView
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
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
