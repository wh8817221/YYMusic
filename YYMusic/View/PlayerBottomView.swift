//
//  PlayerBottomView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class PlayerFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: self.insetY, left: self.insetX, bottom: self.insetY, right: self.insetX)
        self.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        self.minimumLineSpacing = 0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originalAttributesArr = super.layoutAttributesForElements(in: rect)
        //复制布局,以下操作，在复制布局中处理
        var attributesArr: Array<UICollectionViewLayoutAttributes> = Array()
        for attr in originalAttributesArr! {
            attributesArr.append(attr.copy() as! UICollectionViewLayoutAttributes)
        }
        return attributesArr
    }
    
    //MARK 配置方法
    var itemWidth: CGFloat {
        return (self.collectionView?.bounds.size.width)!
    }
    
    var itemHeight: CGFloat {
        return (self.collectionView?.bounds.size.height)!
    }

    //设置左右缩进
    var insetX: CGFloat {
        return ((self.collectionView?.bounds.size.width)!-self.itemWidth)/2
    }
    
    //上下缩进
    var insetY: CGFloat {
        return ((self.collectionView?.bounds.size.height)!-self.itemHeight)/2
    }
    
    //是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class PlayerBottomView: UIView {
    
    static let shared = PlayerBottomView()
    var selectedIndex: Int = 0
    
    fileprivate var playerBarH: CGFloat = 65.0
    fileprivate var collectionView: UICollectionView!
    fileprivate var dragStartX: CGFloat = 0
    fileprivate var dragEndX: CGFloat = 0
    fileprivate var dragAtIndex: Int = 0
    fileprivate var parentVC: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = PlayerFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self)
        }
   
        collectionView.register(UINib(nibName: "PlayerBottomCell", bundle: nil), forCellWithReuseIdentifier: PlayerBottomCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
//        NotificationCenter.addObserver(observer: self, selector: #selector(reloadPlay(_ :)), name: .kReloadPlayStatus)
    }
    
    //MARK:-刷新播放状态
    @objc fileprivate func reloadPlay(_ sender: Notification) {
        if let mode = sender.object as? PlayMode {
            if let cell = collectionView.visibleCells.first as? PlayerBottomCell {
                switch mode {
                case .play, .pause:
                    cell.tapPlayButton(isPlay: mode == .play)
                case .next:
                    cell.nextMusic()
                    cell.playAndPauseBtn.isSelected = true
                case .previous:
                    cell.previousMusic()
                    cell.playAndPauseBtn.isSelected = true
                default:
                    cell.autoNext()
                    cell.playAndPauseBtn.isSelected = true
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(tableView: UITableView, superVc: UIViewController) {
        self.parentVC = superVc
        // tableview  给底部留距离
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: playerBarH+tabHeight))
        superVc.view.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.left.right.equalTo(superVc.view)
            make.bottom.equalTo(superVc.view.snp.bottom).offset(-tabHeight)
            make.height.equalTo(playerBarH)
        }
    }
    
    //刷新界面
    func reloadUI(music: MusicModel) {
        self.collectionView.reloadData()
    }
    
    func reloadData(with index: Int, model: MusicModel) {
        //记录播放状态和播放歌曲角标
        PlayerManager.shared.isPlaying = true
        PlayerManager.shared.index = index
        //播放音乐
        PlayerManager.shared.selectPlayItem(with: model)
        self.collectionView.reloadData()
    }
    
    //手指拖动开始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStartX = scrollView.contentOffset.x
        dragAtIndex = self.selectedIndex
    }
    
    //手指拖动停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragEndX = scrollView.contentOffset.x
        //在主线程执行居中方法
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
    }
    
    //居中
    @objc func fixCellToCenter() {
        if self.selectedIndex != dragAtIndex {
            self.scrollToCenterAnimated(animated: true)
            return
        }
        //最小滚动距离
        let dragMiniDistance = self.bounds.width/10
        if dragStartX - dragEndX >= dragMiniDistance {
            self.selectedIndex -= 1 //向右
        } else if dragEndX - dragStartX >= dragMiniDistance {
            self.selectedIndex += 1 //向右
        }
        let maxIndex = collectionView.numberOfItems(inSection: 0) - 1
        self.selectedIndex = max(self.selectedIndex, 0)
        self.selectedIndex = min(self.selectedIndex, maxIndex)
        self.scrollToCenterAnimated(animated: true)
    }
    
    //滚动到中间
    func scrollToCenterAnimated(animated: Bool) {
        collectionView.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
}

extension PlayerBottomView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerBottomCell.identifier, for: indexPath) as! PlayerBottomCell
        cell.isPlaying = PlayerManager.shared.isPlaying
        cell.musicModel = PlayerManager.shared.currentModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        PlayerManager.shared.presentPlayController(vc: self.parentVC)
    }
}
