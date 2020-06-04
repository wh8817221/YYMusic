//
//  OverlayAnimatedTransitioner.swift
//  baoxiao
//
//  Created by ruanyu on 15/12/31.
//  Copyright © 2015年 schope. All rights reserved.
//

import UIKit

class OverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation : Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromView = fromVC?.view
        let toView = toVC?.view
        let containerView = transitionContext.containerView
        
        if isPresentation {
            containerView.addSubview(toView!)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let animatingView = animatingVC?.view
        
        let appearedFrame = transitionContext.finalFrame(for: animatingVC!)
        var dismissedFrame = appearedFrame
        dismissedFrame.origin.y += dismissedFrame.size.height;
        
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = isPresentation ? appearedFrame : dismissedFrame
        
        animatingView?.frame = initialFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, usingSpringWithDamping:1.0, initialSpringVelocity:5.0, options:[.allowUserInteraction, .beginFromCurrentState], animations:{
            animatingView?.frame = finalFrame
            }, completion:{ (value: Bool) in
                if !self.isPresentation {
                    fromView?.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}

