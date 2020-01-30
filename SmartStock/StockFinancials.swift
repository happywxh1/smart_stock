//
//  SmartStockUtils.swift
//  
//
//  Created by Xiaohong Wang on 7/28/18.
//

import UIKit

class StockFinancial{
    var symbol: String
    var year: Int16
    var earningPerShare: Double!
    var revenue: Double!
    var netIncome: Double!
    var grossMargin: Double!
    var freeCashFlow: Double!
    
    required init(symbol: String, year: Int16) {
        self.symbol = symbol
        self.year = year
    }
}
