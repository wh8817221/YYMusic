//
//  BillListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//
import UIKit
import Kingfisher

enum BillListType: Int {
    //        type:榜单类型（1、新歌榜 2、热歌榜 3、摇滚榜 4、爵士榜 5、流行榜 6、欧美金曲榜 7、经典老歌榜 8、情歌对唱榜 9、影视金曲榜 10、网络金曲榜）
    case new = 1
    case hot = 2
    case rock = 11
    case popular = 16
    case west = 21
    case classic = 22
    case love = 23
    case film = 24
    case net = 25
    
    func getName() -> String {
        switch self {
        case .new:
            return "新歌榜"
        case .hot:
            return "热歌榜"
        case .rock:
            return "摇滚榜"
        case .popular:
            return "流行榜"
        case .west:
            return "欧美金曲榜"
        case .classic:
            return "经典老歌榜"
        case .love:
            return "情歌对唱榜"
        case .film:
            return "影视金曲榜"
        default:
            return "网络金曲榜"
        }
    }
    
}

class BillListViewController: UIViewController {
    
    fileprivate var selectIndex: Int = 0
    fileprivate var pageScrollView: PageScrollView!
    fileprivate var titleScrollView: TitleScrollView! //滚动Title
    
    @IBOutlet weak var contentView: UIView!
    fileprivate var types: [BillListType] = [.new, .hot, .rock, .popular, .west, .classic, .love, .film, .net]
    fileprivate var titles: [String] = []
    fileprivate var controllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lbl = UILabel()
        lbl.text = "全部榜单"
        self.navigationItem.titleView = lbl

        initData()
    
        self.selectViewUI()
    }

    //MARK:-首页布局
    func selectViewUI() {
        var configue = SelectConfigue()
        configue.scrollViewColor = kBlackColor
        configue.defaultButtonColor = .white
        configue.selectButtonColor = kThemeColor
        configue.lineColor = kThemeColor
        
        let frame = CGRect(x: 0, y: contentView.frame.minX, width: screenWidth, height: 44)
        titleScrollView = TitleScrollView(frame: frame, arrTitle: titles, configue: configue)
        titleScrollView.delegate = self
        contentView.addSubview(titleScrollView)
        
        //添加pageView
        pageScrollView = PageScrollView(frame: CGRect.zero, viewControllers: self.controllers, parentVc: self)
        //设置代理可以联动titleScrollView
        pageScrollView.delegate = self
        contentView.addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleScrollView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        //初始化选中的位置
        pageScrollView.selectIndex(index: selectIndex)
    }
    
    func initData() {
        for type in types {
            self.titles.append(type.getName())
            
            let vc = getStoryboardInstantiateViewController(identifier: "TrackListViewController") as? TrackListViewController
            vc?.type = type
            self.controllers.append(vc!)
        }
    }
    
}

extension BillListViewController: PageScrollViewDelegate, TitleScrollViewDelegate {
    
     //MARK:-TitleScrollViewDelegate
    func titleButtonDidSelectedAtIndex(index: Int) {
        pageScrollView.selectIndex(index: index)
    }
    
    //MARK:-PageScrollViewDelegate
    func pageDidScroll(scrollView: UIScrollView) {
        titleScrollView.scrollViewDidScroll(scrollView)
    }
}
