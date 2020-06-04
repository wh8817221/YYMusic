//
//  OverlayPresentationController.swift
//  baoxiao
//
//  Created by ruanyu on 15/12/31.
//  Copyright © 2015年 schope. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    
    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    /**点击阴影消失*/
    var isTapped: Bool = true
    fileprivate var offset: CGFloat = 260.0
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, offset: CGFloat = 260.0) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.offset = offset
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tap)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerVC = self.containerView else {
            return
        }
        dimmingView.frame = containerVC.bounds
        dimmingView.alpha = 0
        containerVC.insertSubview(dimmingView, at: 0)
        
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1
                }, completion: nil)
        } else {
            dimmingView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 0
                }, completion: nil)
        } else {
            dimmingView.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func containerViewWillLayoutSubviews() {
        guard let containerView = self.containerView, let presentedView = presentedView else {
            return
        }
        
        dimmingView.frame = containerView.bounds
        presentedView.frame = frameOfPresentedViewInContainerView
    }
    

    override var frameOfPresentedViewInContainerView : CGRect {
        guard let containerView = self.containerView else {
            return CGRect.zero
        }
        
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerView.bounds
        presentedViewFrame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height

        return presentedViewFrame;
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: self.offset)
    }
    
    @objc func dimmingViewTapped(_ gesture: UIGestureRecognizer) {
        if !isTapped { return }
        if (gesture.state == UIGestureRecognizer.State.recognized) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}
