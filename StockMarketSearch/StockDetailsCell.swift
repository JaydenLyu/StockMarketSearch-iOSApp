//
//  StockDetailsCell.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/2/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class StockDetailsCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var img: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
