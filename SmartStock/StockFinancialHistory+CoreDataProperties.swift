//
//  StockFinancialHistory+CoreDataProperties.swift
//  
//
//  Created by Xiaohong Wang on 7/27/18.
//
//

import Foundation
import CoreData


extension StockFinancialHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockFinancialHistory> {
        return NSFetchRequest<StockFinancialHistory>(entityName: "StockFinancialHistory")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var lastUpdateTime: NSDate?

}


extension StockYearlyData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockYearlyData> {
        return NSFetchRequest<StockYearlyData>(entityName: "StockYearlyData")
    }
    
    @NSManaged public var earningPerShare: Double
    @NSManaged public var freeCashFlow: Double
    @NSManaged public var grossMargin: Double
    @NSManaged public var netIncome: Double
    @NSManaged public var revenue: Double
    @NSManaged public var symbol: String?
    @NSManaged public var year: Int16
    @NSManaged public var owner: StockFinancialHistory?
    
}
