//
//  XHStockInfoDownloader.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/30/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class stockDailyPriceResult{
    var symbol: String?
    var companyName: String = ""
    var dailyPrices: [Date: [String: Double]] = [:]
}

class stockCurrentQuoteInfo{
    var symbol: String?
    var currentPrice:Double
    var companyName: String?
    var todayHigh: Double?
    var todayLow: Double?
    var previousClose: Double?
    var todayOpen: Double?
    required init(symbol: String, price: Double!){
        self.symbol = symbol;
        self.currentPrice = price
    }
}

class XHStockInfoDownloader: NSObject {
    //to fetch stock information from yahoo finance API
    static let apiKey = "UAI3PPF7GSHSOMW5"
    
    class func fetchStockHistoryPrices(stockSymbol:String, completion:@escaping ((stockDailyPriceResult)) -> Void){
        let stockURL = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(stockSymbol)&apikey=\(apiKey)&datatype=json")
        
        let request = URLRequest(url: stockURL!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let result = stockDailyPriceResult()
            if let dict = json as? [String:Any] {
                result.symbol = stockSymbol
                if let innerDict = dict["Time Series (Daily)"] as? [String:Any] {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    for(key, _) in innerDict {
                        let date = formatter.date(from: key)
                        let p = innerDict[key] as? [String:Any]
                        if let open = p!["1. open"] as? String, let close = p!["4. close"] as? String {
                            let prices = ["open": Double(open), "close":Double(close)]
                            result.dailyPrices[date!] = prices as? [String : Double]
                        }
                    }
                }
            }
            completion(result)
        }
        task.resume()
    }
    
    class func fetchStocksCurrentPrices_Deprecate(stockSymbols:[String], completion:@escaping (([stockCurrentQuoteInfo])) -> Void){
        let stockURL = URL(string: "https://www.alphavantage.co/query?function=BATCH_STOCK_QUOTES&symbols=\(stockSymbols.joined(separator: ","))&apikey=\(apiKey)&datatype=json")
        
        let request = URLRequest(url: stockURL!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            var prices = [stockCurrentQuoteInfo]()
            if let dict = json as? [String:Any], let results = dict["Stock Quotes"] as? [Any] {
                for case let price as [String:Any] in results{
                    if let symbol = price["1. symbol"] as? String, let p = price["2. price"] as? String{
                        prices.append(stockCurrentQuoteInfo(symbol: symbol, price: Double(p)))
                    }
                }
            }
            completion(prices)
        }
        task.resume()
    }
    
    class func fetchStocksCurrentPrices(stockSymbols:[String], completion:@escaping (([stockCurrentQuoteInfo])) -> Void){
        let stockURL = URL(string: "https://api.iextrading.com/1.0/stock/market/batch?symbols=\(stockSymbols.joined(separator: ","))&&types=quote&range=1m&last=1")
        
        let request = URLRequest(url: stockURL!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            var stockQuotes = [stockCurrentQuoteInfo]()
            if let dict = json as? [String:Any]{
                for symb in stockSymbols{
                    if let result = dict[symb] as? [String:Any], let quote = result["quote"] as?[String:Any]{
                        let stockQuote = stockCurrentQuoteInfo(symbol: symb, price: quote["latestPrice"] as? Double)
                        stockQuote.companyName = quote["companyName"] as? String
                        stockQuote.todayOpen = quote["open"] as? Double
                        stockQuote.previousClose = quote["open"] as! Double
                        stockQuote.todayHigh = quote["high"] as! Double
                        stockQuote.todayLow = quote["low"] as! Double
                        stockQuotes.append(stockQuote)
                    }
                }
                
            }
            completion(stockQuotes)
        }
        task.resume()
    }
}
