//
//  XHStockListTableViewCell.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/16/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

// define size
let cellHeight = 40.0
let priceChangeLabelHeight = 30.0
let priceChangeLabelWidth = 50.0

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
        priceChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceChangeLabel)
        NSLayoutConstraint.activate([
            priceChangeLabel.widthAnchor.constraint(equalToConstant: CGFloat(priceChangeLabelWidth)),
            priceChangeLabel.heightAnchor.constraint(equalToConstant: CGFloat(priceChangeLabelHeight)),
            priceChangeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            priceChangeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
        
        priceLabel = UILabel()
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            priceLabel.rightAnchor.constraint(equalTo: priceChangeLabel.leftAnchor, constant: -10)
        ])
        
        stockSymbol = UILabel()
        stockSymbol.textAlignment = .left
        stockSymbol.translatesAutoresizingMaskIntoConstraints = false
        
        companyName = UILabel()
        companyName.textAlignment = .left
        companyName.adjustsFontSizeToFitWidth = true
        companyName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stockSymbol)
        contentView.addSubview(companyName)
        
        NSLayoutConstraint.activate([
            stockSymbol.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stockSymbol.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0),
            stockSymbol.heightAnchor.constraint(equalToConstant: 20.0)
        ])
        NSLayoutConstraint.activate([
                   companyName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                   companyName.topAnchor.constraint(equalTo: stockSymbol.topAnchor, constant: 10.0),
               ])
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
        self.layoutSubviews()
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
