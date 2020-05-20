//
//  PageBarView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
enum PageBarViewType {
    case None
    case TextColor    //切换时改变颜色
    case FontSize     //切换时改变字体大小
}
//使用协议进行回掉
protocol PageBarViewDelegate {
    func changeSelected(index:Int);
}

class PageBarView: UIView {
    
    //MARK: - View
    lazy var scrollView:UIScrollView = {[unowned self] in
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
     }()
    lazy var viewLine:UIView = {[unowned self] in
        let lineV = UIView()
        return lineV
    }()

    //MARK: - Data
    var type: PageBarViewType = .None {
        willSet {
            if newValue == .FontSize {
                self.viewLine.backgroundColor = .white
                self.backgroundColor = UIColor.red
            }
            else if newValue == .TextColor {
                self.viewLine.backgroundColor = UIColor.red
            }
        }
    }
    
    var countOfPage:Int = 4
    var titles:Array<String> = [] {
        didSet {
            reloadData()
        }
    }
    var delegate:PageBarViewDelegate?
    
    //MARK - func
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: self.frame.size.height)
        self.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

extension PageBarView {
    func reloadData() {
        
        if titles.count < countOfPage {
            countOfPage = titles.count
        }
        
        let w:CGFloat = frame.size.width / CGFloat.init(countOfPage)
        scrollView.contentSize = CGSize.init(width: w * CGFloat.init(titles.count), height: frame.size.height)
        viewLine.frame = CGRect(x: 0, y: frame.size.height - 2, width: w, height: 2)
        for i in 0..<self.titles.count {
            let btn = UIButton(type: .custom)
            btn.setTitle(titles[i], for: .normal)
            btn.frame = CGRect(x: CGFloat.init(i) * w, y: 0, width: w, height: frame.size.height)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.tag = 10 + i
            btn.isSelected = false
            scrollView.addSubview(btn)
            scrollView.addSubview(viewLine)

            if self.type == .FontSize {
                btn.backgroundColor = UIColor.red
                btn.setTitleColor(.white, for: .selected)
                btn.setTitleColor(.white, for: .normal)
                if  i == 0 {
                    btn.isSelected = true
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                }
            }
            else if self.type == .TextColor {
                btn.backgroundColor = .white
                btn.setTitleColor(UIColor.red, for: .selected)
                btn.setTitleColor(.black, for: .normal)
                if  i == 0 {
                    btn.isSelected = true
                }
            }
        }
    }
    
    @objc func btnAction(_ btn:UIButton) {
        scrollChangeSelected(index: btn.tag)
    }
    
    func scrollChangeSelected(index:Int) {
        for i in 0..<self.titles.count {
            let v = scrollView.viewWithTag(10 + i)
            let btn = v as! UIButton
            if btn.tag != index {
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            } else {
                btn.isSelected = true
                if self.type == .FontSize {
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                }
                
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            let w:CGFloat = self.frame.size.width / CGFloat.init(self.countOfPage)
            var frameOfLine = self.viewLine.frame
            frameOfLine.origin.x = w * CGFloat.init(index - 10)
            self.viewLine.frame = frameOfLine
            if frameOfLine.origin.x >= screenWidth {
                self.scrollView.contentOffset = CGPoint(x: frameOfLine.origin.x - screenWidth + w, y: 0)
            }
            if frameOfLine.origin.x <= w {
                self.scrollView.contentOffset = CGPoint(x:0, y: 0)
            }
        }
        
        if delegate != nil {
            delegate?.changeSelected(index:index - 10)
        }
    }
}

