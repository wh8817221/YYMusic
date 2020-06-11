//
//  ZFTableViewCell.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/26.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class ZFTableViewCell: UITableViewCell {
    static let identifier = String(describing: ZFTableViewCell.self)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
