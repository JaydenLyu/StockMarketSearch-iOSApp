//
//  FavoriteListCell.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/4/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class FavoriteListCell: UITableViewCell {
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cap: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
