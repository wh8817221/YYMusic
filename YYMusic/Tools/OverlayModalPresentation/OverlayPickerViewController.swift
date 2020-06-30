//
//  OverlayPickerViewController.swift
//  baoxiao
//
//  Created by ruanyu on 15/12/31.
//  Copyright © 2015年 schope. All rights reserved.
//

import UIKit

enum OverlayPickerType {
    case normal
    case date
}

class OverlayPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate ,UISearchBarDelegate, UIViewControllerTransitioningDelegate {
    
    var popType: OverlayPickerType = .normal
    var callback: ObjectCallback?
    var isShowSearchTF: Bool = false
    var selectedIndex = 0
    var optionTitle: String? {
        didSet{
            if let t = optionTitle {
                self.titleLabel.text = t
            }
        }
    }
    var optionItems: [Any]! {
        didSet {
            filteredItems = optionItems
        }
    }
    var selectedDate: Date!
    var filteredItems = [Any]()
    var dateStyle: UIDatePicker.Mode = .date
    
    fileprivate lazy var normalPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    fileprivate var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.minimumDate = Date(timeIntervalSince1970: TimeInterval.init())
        return picker
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = kFont16
        label.sizeToFit()
        return label
    }()
    //MARK:懒加载UISearchBar
    fileprivate var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "点击快速搜索"
        search.searchBarStyle = .minimal
        if #available(iOS 13.0, *) {
            search.searchTextField.backgroundColor = UIColor.white
            search.searchTextField.font = kFont14
            search.searchTextField.textColor = UIColor.gray
        } else {
            if let searchField = search.value(forKey: "_searchField") as? UITextField {
                searchField.font = kFont14
                searchField.textColor = UIColor.gray
            }
        }
        return search
    }()
    
    func buildButton(titleName: String, color: UIColor = kThemeColor, font: UIFont = UIFont.systemFont(ofSize: 17) ) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(titleName, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = font
        return btn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = UIView()
        toolbar.backgroundColor = kBackgroundColor
        let cancel = buildButton(titleName: "取消")
        cancel.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        
        let confirm = buildButton(titleName: "确定")
        confirm.addTarget(self, action: #selector(confirmAction(_:)), for: .touchUpInside)
        
        toolbar.addSubview(cancel)
        toolbar.addSubview(confirm)
        
        cancel.snp.makeConstraints { (make) in
            make.left.equalTo(toolbar.snp.left).offset(20)
            make.top.bottom.equalTo(toolbar)
            make.width.equalTo(40)
        }
        
        confirm.snp.makeConstraints { (make) in
            make.right.equalTo(toolbar.snp.right).offset(-20)
            make.top.bottom.equalTo(toolbar)
            make.width.equalTo(40)
        }
        
        switch self.popType {
        case .normal:
            if isShowSearchTF {
                toolbar.addSubview(searchBar)
                searchBar.delegate = self
                searchBar.snp.makeConstraints { (make) in
                    make.left.equalTo(cancel.snp.right).offset(20)
                    make.right.equalTo(confirm.snp.left).offset(-20)
                    make.top.bottom.equalTo(toolbar)
                }
            } else {
                if let text = optionTitle {
                    let titleLbl = UILabel()
                    titleLabel.textColor = UIColor.gray
                    titleLabel.font = kFont17
                    titleLabel.textAlignment = .center
                    titleLbl.text = text
                    toolbar.addSubview(titleLabel)
                    titleLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(cancel.snp.right).offset(20)
                        make.right.equalTo(confirm.snp.left).offset(-20)
                        make.centerY.equalTo(cancel.snp.centerY)
                    }
                }
            }
        case .date:
            if let text = optionTitle {
                let titleLbl = UILabel()
                titleLabel.textColor = UIColor.gray
                titleLabel.font = kFont17
                titleLabel.textAlignment = .center
                titleLbl.text = text
                toolbar.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(cancel.snp.right).offset(20)
                    make.right.equalTo(confirm.snp.left).offset(-20)
                    make.centerY.equalTo(cancel.snp.centerY)
                }
            }
        }
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44).isActive = true
        
        // picker
        switch popType {
        case .normal:
            view.addSubview(normalPicker)
            normalPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
            
            NSLayoutConstraint(item: normalPicker, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: normalPicker, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: normalPicker, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: normalPicker, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
        case .date:
            view.addSubview(datePicker)
            datePicker.datePickerMode = dateStyle
            datePicker.date = selectedDate
            if dateStyle == .time {
                datePicker.locale = Locale(identifier: "en_GB")
            } else {
                datePicker.locale = Locale(identifier: "zh-Hans_CN")
            }
            NSLayoutConstraint(item: datePicker, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: datePicker, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: datePicker, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: datePicker, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //注册通知监听键盘的出现和消失
        NotificationCenter.default.addObserver(self, selector: #selector(OverlayPickerViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OverlayPickerViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action
    @objc func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmAction(_ sender: AnyObject) {
        dismiss(animated: true) { () -> Void in
            switch self.popType {
            case .normal:
                let index = self.normalPicker.selectedRow(inComponent: 0)
                if self.filteredItems.count == 0 {
                    return
                }
                
                if let item = self.filteredItems[index] as? ObjectOption {
                    self.callback?(item)
                }
            case .date:
                let date = self.datePicker.date
                self.callback?(date)
            }
        }
    }
    
    func show() {
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        
        var parentVc: UIViewController?
        let root = UIApplication.shared.keyWindow?.rootViewController
        if root!.isKind(of: UITabBarController.self) {
            let selectVc = (root as! UITabBarController).selectedViewController
            
            if selectVc!.isKind(of: UINavigationController.self) {
                parentVc = (selectVc as! UINavigationController).visibleViewController
            }
            
            if (selectVc!.presentingViewController != nil) {
                parentVc = selectVc!.presentingViewController
            }
        }
        
        if root!.isKind(of: UINavigationController.self) {
            parentVc = (root as! UINavigationController).visibleViewController
        }
        
        if (root!.presentingViewController != nil) {
            parentVc = root!.presentingViewController
        }
        
        parentVc?.present(self, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = filteredItems[row]
        if item is ObjectOption {
            return (item as! ObjectOption).name
        } else {
            return (item as! String)
        }
    }
    
    //MARK:-UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.filteredItems = self.optionItems
        }else {
            self.filteredItems = []
            if let options = self.optionItems as? [ObjectOption] {
                self.filteredItems = options.filter({(ObjectOption) -> Bool in
                    return charactSearch(ObjectOption.name ?? "", searchText: searchText)
                })
            }
            
            if let items = self.optionItems as? [String] {
                self.filteredItems = items.filter({(Object) -> Bool in
                    return charactSearch(Object , searchText: searchText)
                })
            }
            
        }
        self.normalPicker.reloadAllComponents()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.filteredItems = self.optionItems
        self.normalPicker.reloadAllComponents()
    }
    
    func charactSearch(_ characts: String,searchText: String)->Bool{
        return characts.lowercased().contains(searchText.lowercased())
    }
    
    //MARK:键盘的隐藏显示
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let height = keyboardFrame?.size.height
        
        var viewFrame = view.frame
        viewFrame.origin.y =  (screenHeight - viewFrame.size.height) - height!
        view.frame = viewFrame
        
    }
    @objc func keyboardWillHide(_ notification: Notification){
        var viewFrame = view.frame
        viewFrame.origin.y = screenHeight - viewFrame.size.height
        view.frame = viewFrame
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is OverlayPickerViewController {
            let vc = OverlayPresentationController(presentedViewController:presented, presenting:presenting)
            let confige = OverlayModalConfige()
            confige.modelStyle = .bottom
            confige.isPanEnabled = false
            confige.offsetY = UIScreen.main.bounds.height-260
            vc.confige = confige
            return vc
        } else {
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is OverlayPickerViewController {
            let controller = OverlayAnimatedTransitioning()
            controller.isPresentation = true
            return controller
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is OverlayPickerViewController {
            let controller = OverlayAnimatedTransitioning()
            controller.isPresentation = false
            return controller
        } else {
            return nil
        }
    }
}


