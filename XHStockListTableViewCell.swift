//
//  XHStockListTableViewCell.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/16/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit
import SnapKit

class XHStockListTableViewCell: UITableViewCell {
    
    //Mark: Properties
    
    var priceLabel: UILabel!
    var priceChangeLabel: UILabel!
    var stockSymbol : UILabel!
    var companyName : UILabel!
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
        priceChangeLabel = UILabel()
        priceChangeLabel.textAlignment = .right
        contentView.addSubview(priceChangeLabel)
        priceChangeLabel.snp.makeConstraints { (make)->Void in
            make.width.equalTo(30)
            make.right.equalTo(contentView)
        };
        priceLabel = UILabel()
        priceLabel.textAlignment = .right
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make)->Void in
            make.right.equalTo(priceChangeLabel.snp.left).offset(-10)
        };
        
        stockSymbol = UILabel()
        companyName = UILabel()
        stockSymbol.textAlignment = .left
        companyName.textAlignment = .left
        companyName.adjustsFontSizeToFitWidth = true
        contentView.addSubview(stockSymbol)
        contentView.addSubview(companyName)
        
        stockSymbol.snp.makeConstraints { (make)->Void in
            make.top.equalTo(contentView).offset(5)
            make.left.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-20)
        };
        companyName.snp.makeConstraints { (make)->Void in
            make.top.equalTo(stockSymbol).offset(5)
            make.bottom.equalTo(contentView)
        }
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
