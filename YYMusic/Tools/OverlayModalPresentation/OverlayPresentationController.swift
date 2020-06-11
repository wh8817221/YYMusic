//
//  OverlayPresentationController.swift
//  baoxiao
//
//  Created by ruanyu on 15/12/31.
//  Copyright © 2015年 schope. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    //配置信息
    var confige = OverlayModalConfige()
    
    fileprivate lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
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
        let containerBounds = containerView.bounds
        var presentedViewFrame = CGRect.zero
        let tempSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        
        switch confige.modelStyle {
        case .bottom:
            presentedViewFrame.size = tempSize
            presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        case .right:
            presentedViewFrame.size = tempSize
            presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        case .left, .top:
            presentedViewFrame.size = tempSize
        case .center:
            presentedViewFrame.size = tempSize
            presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width)/2
            presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height)/2
        }

        return presentedViewFrame;
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch confige.modelStyle {
        case .bottom, .top:
            return CGSize(width: parentSize.width, height: parentSize.height-confige.offsetY)
        case .left, .right:
            return CGSize(width: parentSize.width-confige.offsetX, height: parentSize.height)
        case .center:
            return CGSize(width: parentSize.width-confige.offsetX, height: parentSize.height-confige.offsetY)
        }
    }
    
    @objc func dimmingViewTapped(_ gesture: UIGestureRecognizer) {
        if !confige.isTappedDismiss { return }
        if (gesture.state == UIGestureRecognizer.State.recognized) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}
