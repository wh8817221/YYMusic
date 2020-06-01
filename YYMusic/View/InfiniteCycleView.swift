//
//  InfiniteCycleView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/29.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

@objc protocol InfiniteCycleViewDelegate: NSObjectProtocol {
    
    func infiniteCycleView(_ scrollView: InfiniteCycleView) -> UIView

    @objc func infiniteCycleView(currentView: UIView?)
    @objc func infiniteCycleView(previousView: UIView?, isEndDragging: Bool)
    @objc func infiniteCycleView(nextView: UIView?, isEndDragging: Bool)
    
    
    @objc func infiniteCycleView(_ scrollView: InfiniteCycleView, didSelectContentViewAt index: Int)
    
}

class InfiniteCycleView: UIView, UIScrollViewDelegate {
    
    weak var delegate: InfiniteCycleViewDelegate? {
        didSet {
            initData()
        }
    }
    fileprivate var currentIndex: Int = 0
    fileprivate var totalIndex: Int = 0
    fileprivate var scrollView: UIScrollView!
    fileprivate var offsetX: CGFloat = 0
    
    var previousView: UIView?
    var currentView: UIView?
    var nextView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildScrollView()
    }
    
    func buildScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self)
        }
    }
    
    func initData() {
        currentIndex = 0
        totalIndex = 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = CGSize(width: self.bounds.width*CGFloat(totalIndex), height: self.bounds.height)
        self.resetContentViews()
    }
    
    func resetContentViews() {
//        //移除scrollView上的所有子视图
//        _ = scrollView.subviews.map({$0.removeFromSuperview()})
//
//        let previousIndex = self.getPreviousPageIndex(with: currentIndex)
//        let nextIndex = self.getNextPageIndex(with: currentIndex)

        if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(_:)))) {
            previousView =
                delegate!.infiniteCycleView(self)
            currentView =
            delegate!.infiniteCycleView(self)
            nextView =
            delegate!.infiniteCycleView(self)
            
            let views = [previousView, currentView, nextView]
            for (i, v) in views.enumerated() {
                v!.frame = CGRect(x: self.frame.width*CGFloat(i), y: 0, width: self.frame.width, height: self.frame.height)
                v?.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapContentView))
                v?.addGestureRecognizer(tapGesture)
                scrollView.addSubview(v!)
            }
            scrollView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
        }
        
    }
    
    @objc fileprivate func tapContentView() {
        if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(_:didSelectContentViewAt:)))) {
            delegate!.infiniteCycleView(self, didSelectContentViewAt: currentIndex)
        }
    }
    
    // 获取当前页上一页的序号
    func getPreviousPageIndex(with currentIndex: Int) -> Int {
        if currentIndex == 0 {
            return totalIndex - 1
        } else {
            return currentIndex - 1
        }
    }
    
    // 获取当前页下一页的序号
    func getNextPageIndex(with currentIndex: Int) -> Int {
        if currentIndex == totalIndex - 1 {
            return 0
        } else {
            return currentIndex + 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x-self.bounds.width
        if offsetX > 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(nextView:isEndDragging:)))) {
                delegate!.infiniteCycleView(nextView: nextView, isEndDragging: false)
            }
        }
        
        if offsetX < 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(previousView:isEndDragging:)))) {
                delegate!.infiniteCycleView(previousView: previousView, isEndDragging: false)
            }
        }

        if offsetX == 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(currentView:)))) {
                delegate!.infiniteCycleView(currentView: currentView)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offsetX = scrollView.contentOffset.x-self.bounds.width
        self.offsetX = offsetX
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //更新当前模型
        //向右
        if offsetX >= self.bounds.width/2 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(nextView:isEndDragging:)))) {
                delegate!.infiniteCycleView(nextView: nextView, isEndDragging: true)
            }
            scrollView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
            
        }
        //向左
        if offsetX < 0 && offsetX <= -(self.bounds.width/2) {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(previousView:isEndDragging:)))) {
                delegate!.infiniteCycleView(previousView: previousView, isEndDragging: true)
            }
            scrollView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
        }
    }
}
