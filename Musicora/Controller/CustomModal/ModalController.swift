//
//  CustomModalController.swift
//  Musicora
//
//  Created by Bora Gündoğu on 22.06.2025.
//

import UIKit
import SnapKit

class CustomModalPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        frameForModalState(modalState)
    }
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var modalState: ModalState = .shortForm
    private var startingFrame: CGRect = .zero
    
    private var shortFormY: CGFloat = 0
    private var longFormY: CGFloat = 0
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
        presentedViewController is CustomModalPresentable else { return }
        
        modalState = .longForm
        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        setupPanGesture()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        updateFrameCalculations()
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        if let presentedVC = presentedViewController as? CustomModalPresentable {
            presentedView?.layer.cornerRadius = presentedVC.cornerRadius
            presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            presentedView?.clipsToBounds = true
        }
    }
    
    private func updateFrameCalculations() {
        guard let containerView = containerView,
              let presentedVC = presentedViewController as? CustomModalPresentable else { return }
        
        let containerHeight = containerView.bounds.height
        longFormY = max(containerView.safeAreaInsets.top + 20, containerHeight - presentedVC.longFormHeight)
    }
    
    private func frameForModalState(_ state: ModalState) -> CGRect {
        guard let containerView = containerView else { return .zero }
        let width = containerView.bounds.width
        let yPosition: CGFloat
        let height: CGFloat
        
        switch state {
        case .shortForm:
            yPosition = shortFormY
            height = containerView.bounds.height - shortFormY
        case .longForm:
            yPosition = longFormY
            height = containerView.bounds.height - longFormY
        case .dismissed:
            yPosition = containerView.bounds.height
            height = containerView.bounds.height
        }
        
        return CGRect(x: 0, y: yPosition, width: width, height: height)
    }
    
    private func setupPanGesture() {
        guard let presentedView = presentedView,
              let presentedVC = presentedViewController as? CustomModalPresentable,
              presentedVC.allowsDismissalByPan else { return }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        presentedView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func dimmingViewTapped() {
        guard let presentedVC = presentedViewController as? CustomModalPresentable,
              presentedVC.allowsDismissalByTap else { return }
        presentedViewController.dismiss(animated: true)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView,
              let containerView = containerView else { return }
        
        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        
        switch gesture.state {
        case .began:
            startingFrame = presentedView.frame
        case .changed:
            let newY = startingFrame.origin.y + translation.y
            let clampedY = max(longFormY, min(newY, containerView.bounds.height))
            presentedView.frame.origin.y = clampedY
            updateDimmingAlpha(for: clampedY)
        case .ended, .cancelled:
            handlePanGestureEnded(translation: translation, velocity: velocity)
        default:
            break
        }
    }
    
    private func handlePanGestureEnded(translation: CGPoint, velocity: CGPoint) {
        guard let presentedView = presentedView else { return }
        
        let currentY = presentedView.frame.origin.y
        let velocityThreshold: CGFloat = 1200
        let modalHeight = presentedView.bounds.height
        let dismissThreshold = longFormY + (modalHeight * 0.3)
        
        let targetState: ModalState = {
            if velocity.y > velocityThreshold || currentY > dismissThreshold {
                return .dismissed
            } else {
                return .longForm
            }
        }()
        
        if targetState == .dismissed {
            presentedViewController.dismiss(animated: true)
        } else {
            animateToState(targetState)
        }
    }
    
    private func animateToState(_ state: ModalState) {
        modalState = state
        let targetFrame = frameForModalState(state)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.presentedView?.frame = targetFrame
            self.dimmingView.alpha = 1
        }
    }
    
    private func updateDimmingAlpha(for yPosition: CGFloat) {
        guard let containerView = containerView else { return }
        let progress = (yPosition - longFormY) / (containerView.bounds.height - longFormY)
        dimmingView.alpha = max(0.4 * (1 - progress), 0)
    }
    
    private func addDragIndicator(to view: UIView) {
        let handleView = UIView()
        handleView.backgroundColor = UIColor.systemGray3
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(handleView)
        NSLayoutConstraint.activate([
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    private static var transitionManagerKey: Int = 0
    
    private var customModalTransitionManager: CustomModalTransitionManager? {
        get { objc_getAssociatedObject(self, &UIViewController.transitionManagerKey) as? CustomModalTransitionManager }
        set { objc_setAssociatedObject(self, &UIViewController.transitionManagerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func presentCustomModal(_ viewController: UIViewController) {
        let manager = CustomModalTransitionManager()
        self.customModalTransitionManager = manager
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = manager
        present(viewController, animated: true)
    }
}
