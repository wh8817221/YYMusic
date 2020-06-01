//
//  InfiniteCycleView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/29.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

@objc protocol InfiniteCycleViewDelegate: NSObjectProtocol {
    //初始化视图
    func infiniteCycleView(_ scrollView: InfiniteCycleView) -> UIView
    //视图滚动处理模型变化
    @objc func infiniteCycleView(currentView: UIView?)
    @objc func infiniteCycleView(previousView: UIView?, isEndDragging: Bool)
    @objc func infiniteCycleView(nextView: UIView?, isEndDragging: Bool)
    //当前视图选中
    @objc func infiniteCycleViewDidSelect(_ currentView: UIView?)
    
}

class InfiniteCycleView: UIView, UIScrollViewDelegate {
    
    weak var delegate: InfiniteCycleViewDelegate?
    fileprivate var totalIndex: Int = 3
    fileprivate var scrollView: UIScrollView!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = CGSize(width: self.bounds.width*CGFloat(totalIndex), height: self.bounds.height)
        self.setViews()
    }
    
    func setViews() {
        //保证永远只有三个视图滚动
        if previousView != nil && currentView != nil && nextView != nil {
            return
        }
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
                //只给当前视图添加点击事件
                if v == currentView {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapContentView))
                    v?.addGestureRecognizer(tapGesture)
                }
                scrollView.addSubview(v!)
            }
            //滚动到中间视图
            scrollView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
        }
        
    }
    
    @objc fileprivate func tapContentView() {
        if (delegate!.responds(to: #selector(delegate?.infiniteCycleViewDidSelect(_:)))) {
            delegate!.infiniteCycleViewDidSelect(self.currentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x-self.bounds.width
        //向右滚动,获取下一个视图模型
        if offsetX > 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(nextView:isEndDragging:)))) {
                delegate!.infiniteCycleView(nextView: nextView, isEndDragging: false)
            }
        }
        //向左滚动,获取前一个视图模型
        if offsetX < 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(previousView:isEndDragging:)))) {
                delegate!.infiniteCycleView(previousView: previousView, isEndDragging: false)
            }
        }
        //获取当前视图模型
        if offsetX == 0 {
            if (delegate!.responds(to: #selector(delegate?.infiniteCycleView(currentView:)))) {
                delegate!.infiniteCycleView(currentView: currentView)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x-self.bounds.width
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
