//
//  CoreDataStack.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 7/5/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import CoreData

class CoreDataStack: NSObject {
    static let sharedInstance = CoreDataStack()
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "StockFinancials")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Helper
    func saveStockFinancialHistoryEntityFrom(symbol:String, financials: [StockFinancial]){
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let financialEntity = NSEntityDescription.insertNewObject(forEntityName: "StockFinancialHistory", into: context) as! StockFinancialHistory
        financialEntity.symbol = symbol
        financialEntity.lastUpdateTime = Date() as NSDate
        
        for entry in financials {
            let yearlyData = NSEntityDescription.insertNewObject(forEntityName: "StockYearlyData", into: context) as! StockYearlyData
            yearlyData.year = entry.year
            yearlyData.freeCashFlow = entry.freeCashFlow
            yearlyData.revenue = entry.revenue
            yearlyData.netIncome = entry.netIncome
            yearlyData.grossMargin = entry.grossMargin
            yearlyData.earningPerShare = entry.earningPerShare
            yearlyData.owner = financialEntity
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save stock yearly data. \(error), \(error.userInfo)")
            }
        }

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchFinancialHistoryOfStock(symbol:String) -> StockFinancialHistory?{
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<StockFinancialHistory> = StockFinancialHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            if fetchedResults.count > 0 {
                return fetchedResults.first
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
    }
}
