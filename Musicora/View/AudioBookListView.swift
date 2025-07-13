//
//  AudioBookListView.swift
//  Musicora
//
//  Created by Bora Gündoğu on 17.05.2025.
//

import UIKit
import SnapKit

final class AudioBookListView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AudioBookCell.self, forCellReuseIdentifier: "AudioBookCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "bg")
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
