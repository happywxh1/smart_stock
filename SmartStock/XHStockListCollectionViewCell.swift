//
//  XHStockListTableViewCell.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/16/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit
import SnapKit

// define size
let cellHeight = 40.0
let priceChangeLabelHeight = 30
let priceChangeLabelWidth = 50

class XHStockListCollectionViewCell: UICollectionViewCell {
    
    //Mark: Properties
    
    var priceLabel: UILabel!
    var priceChangeLabel: UILabel!
    var stockSymbol : UILabel!
    var companyName : UILabel!
    var currentPriceChange: Double! //compare with yestery
    
    var stockInfo: stockCurrentQuoteInfo? {
        didSet {
            if let s = stockInfo {
                priceLabel.text = String(format: "%.02f",s.currentPrice)
                stockSymbol.text = s.symbol
                companyName.text = s.companyName
                currentPriceChange = s.currentPrice - s.previousClose!
                priceChangeLabel.text = String(format: "%.02f",self.currentPriceChange)
                priceChangeLabel.backgroundColor = (self.currentPriceChange>0 ? .green : .red)
                setNeedsLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        priceChangeLabel = UILabel()
        priceChangeLabel.textAlignment = .right
        contentView.addSubview(priceChangeLabel)
        priceChangeLabel.snp.makeConstraints { (make)->Void in
            make.width.equalTo(priceChangeLabelWidth)
            make.height.equalTo(priceChangeLabelHeight)
            make.centerY.equalTo(contentView.snp.centerY)
            make.right.equalTo(contentView).offset(-10)
        };
        priceLabel = UILabel()
        priceLabel.textAlignment = .right
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make)->Void in
            make.right.equalTo(priceChangeLabel.snp.left).offset(-10)
            make.top.bottom.equalTo(contentView)
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
            make.height.equalTo(20)
        };
        companyName.snp.makeConstraints { (make)->Void in
            make.top.equalTo(stockSymbol).offset(10)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
    }
    
    class func cellSize() -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width, height: CGFloat(cellHeight))
    }
    
}
