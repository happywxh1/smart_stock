//
//  XHStockListTableViewCell.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/16/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class XHStockListTableViewCell: UITableViewCell {
    
    //Mark: Properties
    
    @IBOutlet weak var stockName: UILabel!
    @IBOutlet weak var stockCurrentPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
