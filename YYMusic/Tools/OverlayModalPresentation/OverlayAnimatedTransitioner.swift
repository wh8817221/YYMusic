//
//  OverlayAnimatedTransitioner.swift
//  baoxiao
//
//  Created by ruanyu on 15/12/31.
//  Copyright © 2015年 schope. All rights reserved.
//

import UIKit

class OverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    //配置信息
    var confige = OverlayModalConfige()
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
        
        var initialFrame = CGRect.zero
        var finalFrame = CGRect.zero
        
        let appearedFrame = transitionContext.finalFrame(for: animatingVC!)
        var dismissedFrame = appearedFrame
        
        switch confige.modelStyle {
        case .bottom:
            dismissedFrame.origin.y += dismissedFrame.size.height
        case .top:
            dismissedFrame.origin.y -= dismissedFrame.size.height
        case .right:
            dismissedFrame.origin.x += dismissedFrame.size.width
        case .left:
            dismissedFrame.origin.x -= dismissedFrame.size.width
        case .center:
            let newTransform = animatingView?.transform.scaledBy(x: 0.5, y: 0.5)
            animatingView?.transform = newTransform!
            break
        }
        
        initialFrame = isPresentation ? dismissedFrame : appearedFrame
        finalFrame = isPresentation ? appearedFrame : dismissedFrame
        
        animatingView?.frame = initialFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, usingSpringWithDamping:1.0, initialSpringVelocity: 5.0, options:[.allowUserInteraction, .beginFromCurrentState], animations:{
            animatingView?.frame = finalFrame
            if self.confige.modelStyle == .center {
                if self.isPresentation {
                    let newTransform = animatingView?.transform.scaledBy(x: 2.0, y: 2.0)
                    animatingView?.transform = newTransform!
                } else {
                    let newTransform = animatingView?.transform.scaledBy(x: 0.1, y: 0.1)
                    animatingView?.transform = newTransform!
                }
            }
            }, completion:{ (value: Bool) in
                if !self.isPresentation {
                    fromView?.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}

