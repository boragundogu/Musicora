//
//  CustomModalPresentable.swift
//  Musicora
//
//  Created by Bora Gündoğu on 22.06.2025.
//

import UIKit
import SnapKit

// MARK: - Custom Modal Presentable Protocol
protocol CustomModalPresentable: UIViewController {
    var longFormHeight: CGFloat { get }
    var cornerRadius: CGFloat { get }
    var allowsDismissalByPan: Bool { get }
    var allowsDismissalByTap: Bool { get }
}

// MARK: - Modal State
enum ModalState {
    case shortForm
    case longForm
    case dismissed
}
