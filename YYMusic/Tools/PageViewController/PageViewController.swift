//
//  PageViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//
import UIKit

class PageViewController: UIPageViewController {
    lazy var pageBarView: PageBarView = {[unowned self] in
        let v = PageBarView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        v.delegate = self
        return v
    }()
    
    var allViewControllers: Array<UIViewController>? {
        didSet {
            self.showIndex(index: 0)
        }
    }
    var allTitles:Array<String>? {
        didSet {
            self.pageBarView.titles = allTitles!
        }
    }
    /**滚动角标的回调*/
    var callback: ((_ index: Int) -> Void)?
    convenience init() {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        self.view.addSubview(pageBarView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.dataSource = self
        self.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension PageViewController {
    func showPage(index: Int) {
        let btn = self.pageBarView.scrollView.viewWithTag(index + 10) as? UIButton
        self.pageBarView.btnAction(btn!)
    }
    
    func showIndex(index:Int) {
        if self.viewControllers?.count == 0 {
            setViewControllers([(allViewControllers?[index])! ], direction:.forward, animated: true, completion: nil)
        } else {
            let page = allViewControllers?.firstIndex(of: self.viewControllers![0])
            if page! < index {
                setViewControllers([(allViewControllers?[index])! ], direction:.forward, animated: true, completion: nil)
            }
            else if page! > index {
                setViewControllers([(allViewControllers?[index])! ], direction:.reverse, animated: true, completion: nil)
            }
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = allViewControllers?.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard (allViewControllers?.count)! > previousIndex else {
            return nil
        }
        return allViewControllers?[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = allViewControllers?.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = allViewControllers?.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount! > nextIndex else {
            return nil
        }
        return allViewControllers?[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let page = allViewControllers?.firstIndex(of: self.viewControllers![0])
        pageBarView.scrollChangeSelected(index: page! + 10)
    }
}

extension PageViewController: PageBarViewDelegate {
    func changeSelected(index: Int) {
        showIndex(index: index)
        if let callback = self.callback {
            callback(index)
        }
    }
    //选择音乐/歌词
    func selectedSegmentControl(index: Int) {
        showIndex(index: index)
    }
}
