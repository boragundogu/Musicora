//
//  ModalAnimator.swift
//  Musicora
//
//  Created by Bora Gündoğu on 22.06.2025.
//

import UIKit

class CustomModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    init(isPresenting: Bool) { self.isPresenting = isPresenting }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        
        /* if isPresenting {
            animatePresentation(using: context)
        } else {
            animateDismissal(using: context)
        }
         */
        
        (isPresenting ? animatePresentation : animateDismissal)(context)
        
        // isPresenting ? animateDismissal(using: context) : animateDismissal(using: context)
        
        // MARK: Void Function in Ternary Violation: Using ternary to call Void functions should be avoided (void_function_in_ternary)
    }
    
    private func animatePresentation(using context: UIViewControllerContextTransitioning) {
        guard let toVC = context.viewController(forKey: .to),
              let toView = context.view(forKey: .to),
              let presentedVC = toVC as? CustomModalPresentable else {
            context.completeTransition(false)
            return
        }
        
        let container = context.containerView
        let finalFrame = context.finalFrame(for: toVC)
        toView.layer.cornerRadius = presentedVC.cornerRadius
        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        toView.clipsToBounds = true
        
        toView.frame = CGRect(x: 0, y: container.bounds.height, width: finalFrame.width, height: finalFrame.height)
        container.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            toView.frame = finalFrame
        } completion: { finished in
            context.completeTransition(finished)
        }
    }
    
    private func animateDismissal(using context: UIViewControllerContextTransitioning) {
        guard let fromView = context.view(forKey: .from) else {
            context.completeTransition(false)
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn) {
            fromView.frame.origin.y = context.containerView.bounds.height
        } completion: { finished in
            context.completeTransition(finished)
        }
    }
}

extension CustomModalPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: presentedView)
        return abs(velocity.y) > abs(velocity.x)
    }
}
