//
//  SmartStockUtils.swift
//  
//
//  Created by Xiaohong Wang on 7/28/18.
//

import UIKit

enum StockFinancialParams:Int{
    case kStockEarningPerShare = 1 // = "Earnings Per Share"
    case kStockRevenue //= "Revenue"
    case kStockGrossMargin // = "Gross Margin"
    case kStockNetIncome //= "Net Income"
    case kStockFreeCashFlow //= "Free Cash Flow"
    case kStockNumberOfShares //= "Shares"
    
    func description() -> String {
        switch self {
        case .kStockRevenue:
            return "Revenue"
        case .kStockNetIncome:
            return "Net Income"
        case .kStockFreeCashFlow:
            return "Free Cash Flow"
        case .kStockGrossMargin:
            return "Gross Margin"
        case .kStockEarningPerShare:
            return "Earnings Per Share"
        case .kStockNumberOfShares:
            return "Shares"
        }
    }

    static func allFinancialParams() -> [String]{
        var params = [String]()
        for i in StockFinancialParams.kStockEarningPerShare.rawValue...StockFinancialParams.kStockNumberOfShares.rawValue {
            params.append(StockFinancialParams.init(rawValue: i)!.description())
        }
        return params
    }
    //static let allFinancialParams = StockFinancialParams.kStockEarningPerShare.rawValue...StockFinancialParams.kStockNumberOfShares.rawValue
}
