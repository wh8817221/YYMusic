//
//  ProductPageViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class ProductPageViewController: UIViewController {
    
    lazy var VCs: [UIViewController] = { [unowned self] in
        let allVC = TestViewController()
        allVC.state = 1
        
        let onVC = TestViewController()
        onVC.state = 2
        
        let vcs = [allVC, onVC]
        return vcs
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        let pageVC = PageViewController()
        pageVC.pageBarView.type = .FontSize
        pageVC.allViewControllers = VCs
        pageVC.allTitles = ["歌曲","歌词"]

        addChild(pageVC)
        view.addSubview(pageVC.view)
        let rect = view.bounds
        pageVC.view.frame = rect
        pageVC.didMove(toParent: self)
        view.gestureRecognizers = pageVC.gestureRecognizers
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
