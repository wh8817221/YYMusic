//
//  LrcCell.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/4.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class LrcCell: UITableViewCell {

    static let identifier = String(describing: LrcCell.self)
    var lrcLbl: LrcLabel!
    
    var progress: CGFloat = 0 {
        didSet {
            lrcLbl.progress = progress
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        lrcLbl = LrcLabel()
        lrcLbl.textColor = .white
        lrcLbl.font = kFont15
        lrcLbl.textAlignment = .center
        self.contentView.addSubview(lrcLbl)
        
        lrcLbl.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
        }
    }
    
    class func cellWithTableView(_ tableView: UITableView) -> LrcCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: LrcCell.identifier) as? LrcCell
        if cell ==  nil {
            cell = LrcCell(style: .default, reuseIdentifier: LrcCell.identifier)
        }
        return cell!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
