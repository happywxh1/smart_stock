//
//  StockFinancialHistory+CoreDataProperties.swift
//  
//
//  Created by Xiaohong Wang on 7/5/18.
//
//

import Foundation
import CoreData


extension StockFinancialHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockFinancialHistory> {
        return NSFetchRequest<StockFinancialHistory>(entityName: "StockFinancialHistory")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var revenue: [Int:Double]?
    @NSManaged public var netIncome: [Int:Double]?
    @NSManaged public var freeCashFlow: [Int:Double]?
    @NSManaged public var lastUpdateTime: NSDate?

}
