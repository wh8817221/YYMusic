//
//  BaseNavigationViewController.swift
//  baoxiao
//
//  Created by 王浩 on 2017/12/28.
//  Copyright © 2017年 schope. All rights reserved.

import UIKit

class BaseNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let count = self.children.count
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(dismissViewController))
        if count >= 1 {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(popVc))
            viewController.hidesBottomBarWhenPushed = true
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
        super.pushViewController(viewController, animated: animated)
        
    }
    

    @objc func dismissViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func popVc() {
        self.popViewController(animated: true)
    }
    
}

