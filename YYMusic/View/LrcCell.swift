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
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
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
