//
//  CustomModalTransition.swift
//  Musicora
//
//  Created by Bora Gündoğu on 22.06.2025.
//

import UIKit

class CustomModalTransitionManager: NSObject {}

extension CustomModalTransitionManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        CustomModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomModalAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomModalAnimator(isPresenting: false)
    }
}
