
import UIKit

class SelectScrollview: UIView{
    
    var callback: ObjectCallback?
    
    fileprivate var viewControllers = [UIViewController]()
    fileprivate weak var parentVc: UIViewController?
    fileprivate lazy var viewConrtollerScroll:UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        scroll.bounces = false
        scroll.delegate = self
        scroll.isPagingEnabled = true
        return scroll
    }()
    
    fileprivate var dicForVC:[Int: UIViewController] = [:]
    
    fileprivate var currentPage:Int = -1 {
        didSet {
            guard let _ = dicForVC[currentPage]  else {
                dicForVC[currentPage] = self.viewControllers[currentPage]
                self.viewConrtollerScroll.addSubview(self.viewControllers[currentPage].view)
                self.parentVc?.addChild(self.viewControllers[currentPage])
                
                self.viewControllers[currentPage].view.snp.makeConstraints({ (make) in
                    make.left.equalTo(CGFloat(self.currentPage)*screenWidth)
                    make.top.equalTo(0)
                    make.size.equalTo(CGSize.init(width: screenWidth, height: self.bounds.height))
                })
                return
            }
        }
    }

    convenience init(frame: CGRect, viewControllers:[UIViewController], parentVc: UIViewController) {
        self.init(frame: frame)
        self.viewControllers = viewControllers
        self.parentVc = parentVc
        createUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.viewControllers.isEmpty { return }
        
        let width = CGFloat(viewControllers.count)*screenWidth
        let height = self.bounds.height
        viewConrtollerScroll.contentSize = CGSize(width: width, height: height)

        for (_,vc) in dicForVC {
            vc.view.snp.updateConstraints({ (make) in
                make.size.equalTo(CGSize(width: screenWidth, height: self.bounds.height))
            })
        }
    }
    
    func createUI() {
        if self.viewControllers.isEmpty { return }
        let width = CGFloat(viewControllers.count)*screenWidth
        let height = self.bounds.height - 88
        viewConrtollerScroll.contentSize = CGSize(width: width, height: height)
        self.addSubview(viewConrtollerScroll)
        viewConrtollerScroll.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
    }
    
    //MARK:-选中的位置
    func selectIndex(index: Int) {
        self.layoutIfNeeded()
        self.currentPage = index
        UIView.animate(withDuration: 0.3) {
            self.viewConrtollerScroll.contentOffset.x = CGFloat(index)*screenWidth
        }
    }
}

extension SelectScrollview: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == viewConrtollerScroll {
            self.currentPage  = Int((scrollView.contentOffset.x + screenWidth/2)/screenWidth)
        }
    }
    
    //MARK: - scrollView delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.callback?(self.currentPage)
    }
}

