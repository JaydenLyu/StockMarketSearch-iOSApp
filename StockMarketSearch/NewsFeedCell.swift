//
//  NewsFeedCell.swift
//  StockMarketSearch
//
//  Created by Jibin Lyu on 5/3/16.
//  Copyright © 2016 Jibin Lyu. All rights reserved.
//

import UIKit

class NewsFeedCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var detail: UILabel!
    
    @IBOutlet weak var source: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
