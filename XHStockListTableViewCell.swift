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
    
    var priceLabel: UILabel!
    var priceChangeLabel: UILabel!
    var stockSymbol : UITextField!
    var companyName : UITextField!
    var currentPriceChange: Double! //compare with yestery
    
    var stockInfo: stockCurrentQuoteInfo? {
        didSet {
            if let s = stockInfo {
                priceLabel.text = String(format: "%.00f",s.currentPrice)
                stockSymbol.text = s.symbol
                companyName.text = s.companyName
                currentPriceChange = s.currentPrice - s.previousClose!
                priceChangeLabel.text = String(format: "%.00f",self.currentPriceChange)
                priceChangeLabel.backgroundColor = (self.currentPriceChange>0 ? .green : .red)
                setNeedsLayout()
            }
        }
    }
        
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        priceLabel = UILabel(frame:CGRect(x: self.frame.width-50, y: 0, width: 100, height: 50))
        priceLabel.textAlignment = .left
        contentView.addSubview(priceLabel)
        
        priceChangeLabel = UILabel(frame:CGRect(x: self.frame.width, y: 0, width: 30, height: 50))
        priceChangeLabel.textAlignment = .right
        contentView.addSubview(priceChangeLabel)
        
        stockSymbol = UITextField(frame: CGRect(x:10, y: 0, width: 60, height: 40))
        stockSymbol.textAlignment = .left
        companyName = UITextField(frame: CGRect(x:10, y: 20, width: 200, height: 20))
        companyName.textAlignment = .left
        companyName.adjustsFontSizeToFitWidth = true
        contentView.addSubview(stockSymbol)
        contentView.addSubview(companyName)
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
