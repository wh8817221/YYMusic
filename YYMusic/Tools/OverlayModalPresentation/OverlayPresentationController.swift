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
    fileprivate var isFinishedAnimation: Bool = true
    fileprivate var pointStart: CGPoint? //触摸开始的坐标
    fileprivate var pointLast: CGPoint? //上一次触摸的坐标
    fileprivate var pointEnd: CGPoint? //最后一次触摸的坐标//是否结束动画
    fileprivate var originCenter: CGPoint = CGPoint.zero
    fileprivate lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        dimmingView.addGestureRecognizer(pan)
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
        
        //center模式下不加入滑动手势
        if confige.modelStyle != .center {
            //加入滑动手势
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            dimmingView.addGestureRecognizer(pan)
            self.presentedView?.addGestureRecognizer(pan)
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
        originCenter = presentedView.center
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
    
    
    @objc fileprivate func pan(_ sender: UIPanGestureRecognizer) {
        guard let presentedView = self.presentedView else {
            return
        }
        if !isFinishedAnimation { return }
        let translation = sender.translation(in: dimmingView)
        /**滑动速度--speed.y > 920表示关闭意图*/
        let speedPoint = sender.velocity(in: dimmingView)
        if sender.state == .began {
            self.pointStart = translation
        }
        
        if sender.state == .changed {
            switch confige.modelStyle {
            case .bottom: //向下滑动
                let yMove = translation.y - self.pointStart!.y
                if yMove > 0 {
                    presentedView.center = CGPoint(x: originCenter.x, y: originCenter.y+yMove)
                    dimmingView.alpha = 1-(yMove/presentedView.frame.height)
                }
            case .top:  //向上滑动
                
                let yMove = translation.y - self.pointStart!.y
                if yMove < 0 {
                    presentedView.center = CGPoint(x: originCenter.x, y: originCenter.y+yMove)
                    dimmingView.alpha = 1+(yMove/presentedView.frame.height)
                }
            case .right:  //向右滑动
                let xMove = translation.x - self.pointStart!.x
                if xMove > 0 {
                    presentedView.center = CGPoint(x: originCenter.x+xMove, y: originCenter.y)
                    dimmingView.alpha = 1-(xMove/presentedView.frame.width)
                }
            case .left:  //向左滑动
                let xMove = translation.x - self.pointStart!.x
                if xMove < 0 {
                    presentedView.center = CGPoint(x: originCenter.x+xMove, y: originCenter.y)
                    dimmingView.alpha = 1+(xMove/presentedView.frame.width)
                }
            default:
                break
            }
            
        }
        
        if sender.state == .ended {
            
            switch confige.modelStyle {
            case .bottom: //向下滑动
                let yTotalMove = translation.y - self.pointStart!.y
                if yTotalMove > presentedView.frame.height/4 || speedPoint.y > 920 {
                    presentingViewController.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        presentedView.center = self.originCenter
                        self.dimmingView.alpha = 1
                    })
                }
            case .top:  //向上滑动
                let yTotalMove = translation.y - self.pointStart!.y
                if yTotalMove < -presentedView.frame.height/4 || speedPoint.y < -920 {
                    presentingViewController.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        presentedView.center = self.originCenter
                        self.dimmingView.alpha = 1
                    })
                }
            case .right: //向右滑动
                let xTotalMove = translation.x - self.pointStart!.x
                if xTotalMove > presentedView.frame.width/4 || speedPoint.x > 920 {
                    presentingViewController.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        presentedView.center = self.originCenter
                        self.dimmingView.alpha = 1
                    })
                }
            case .left: //向左滑动
                let xTotalMove = translation.x - self.pointStart!.x
                if xTotalMove < -presentedView.frame.width/4  || speedPoint.x < -920 {
                    presentingViewController.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        presentedView.center = self.originCenter
                        self.dimmingView.alpha = 1
                    })
                }
            default:
                break
            }
            
        }
    }
}
