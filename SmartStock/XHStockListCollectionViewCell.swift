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
    var stockInfo: StockCurrentQuote?
    
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.text = nil
        companyName.text = nil
        priceChangeLabel.text = nil
        stockSymbol.text = nil
    }
    
    func setStockInfo(quote:StockCurrentQuote?, keyStats: StockKeyStats?) -> Void {
        if quote == nil || keyStats == nil {
            return
        }
        priceLabel.text = String(format: "%.02f", quote!.latestPrice)
        stockSymbol.text = quote!.symbol
        companyName.text = keyStats!.companyName
        currentPriceChange = quote!.latestPrice - quote!.previousClose
        priceChangeLabel.text = String(format: "%.02f",self.currentPriceChange)
        priceChangeLabel.backgroundColor = (self.currentPriceChange>0 ? .green : .red)
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
