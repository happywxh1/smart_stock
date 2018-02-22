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
    
    var priceLabel:UILabel!
    var stockName : UITextField!
    
    var stockInfo: stockPriceInfo? {
        didSet {
            if let s = stockInfo {
                priceLabel.text = String(format: "%.00f",s.currentPrice!)
                priceLabel.backgroundColor = UIColor.green
                stockName.text = s.symbol
                setNeedsLayout()
            }
        }
    }
        
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        priceLabel = UILabel(frame:CGRect(x: self.frame.width-50, y: 0, width: 100, height: 40))
        priceLabel.textAlignment = .right
        contentView.addSubview(priceLabel)
        
        stockName = UITextField(frame: CGRect(x:20, y: 0, width: 100, height: 50))
        stockName.textAlignment = .left
        contentView.addSubview(stockName)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
    }
}
