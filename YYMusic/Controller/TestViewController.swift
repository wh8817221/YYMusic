//
//  TestViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    var state: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        let lbl = UILabel()
        lbl.text = "当前页面\(state!)"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(lbl)
        
        lbl.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self.view)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
