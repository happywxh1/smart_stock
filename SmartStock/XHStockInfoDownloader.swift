//
//  XHStockInfoDownloader.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/30/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

struct StockFinancialCurrency {
    static let kStockCurrencyUSD = "USD"
    static let kStockCurrencyRMB = "RMB"
}


class stockDailyPriceResult{
    var symbol: String?
    var companyName: String = ""
    var dailyPrices: [Date: [String: Double]] = [:]
}

class stockCurrentQuoteInfo{
    var symbol: String?
    var currentPrice:Double
    var companyName: String?
    var todayHigh: Double!
    var todayLow: Double!
    var previousClose: Double!
    var todayOpen: Double!
    var peRatio: Double!
    var week52High: Double!
    var week52Low: Double!
    var ttmEPS: Double!
    var marketCap: Double!
    var dividend: Double!
    var dividendRate: Double! //for the percentage
    var latestVolume: Double!   //in the unit of Million
    
    required init(symbol: String, price: Double!){
        self.symbol = symbol;
        self.currentPrice = price
    }
}

enum chartType{
    case OneDay
    case FiveDays
    case OneMonth
    case OneYear
}

class XHStockInfoDownloader: NSObject {
    //to fetch stock information from finance API
    let apiKey = "UAI3PPF7GSHSOMW5"
    let baseURL = "https://api.iextrading.com/1.0/"
    var financialParams: Array<String>?
    let performQueue = DispatchQueue(label: "stockInfoDownloader", attributes: .concurrent)
    static let sharedInstance = XHStockInfoDownloader()
    
    override init() {
        super.init()
        self.financialParams = StockFinancialParams.allFinancialParams()
    }
    
    /*
    class func fetchStockHistoryPrices_Deprecate(stockSymbol:String, completion:@escaping ((stockDailyPriceResult)) -> Void){
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
    */
    func fetchStocksCurrentPrices(stockSymbols:[String], completion:@escaping (([stockCurrentQuoteInfo])) -> Void){
        performQueue.async {
            let stockURL = URL(string: (self.baseURL+"stock/market/batch?symbols=\(stockSymbols.joined(separator: ","))&&types=quote,stats&range=1m&last=1"))
            
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
                        if let result = dict[symb] as? [String:Any], let quote = result["quote"] as?[String:Any],
                            let stats = result["stats"] as?[String:Any] {
                            let stockQuote = stockCurrentQuoteInfo(symbol: symb, price: quote["latestPrice"] as? Double)
                            stockQuote.companyName = quote["companyName"] as? String
                            stockQuote.todayOpen = quote["open"] as! Double
                            stockQuote.previousClose = quote["open"] as! Double
                            stockQuote.todayHigh = quote["high"] as! Double
                            stockQuote.todayLow = quote["low"] as! Double
                            stockQuote.week52Low = quote["week52Low"] as! Double
                            stockQuote.week52High = quote["week52High"] as! Double
                            stockQuote.peRatio = quote["peRatio"] as! Double
                            stockQuote.marketCap = quote["marketCap"] as! Double
                            stockQuote.latestVolume = (quote["latestVolume"] as! Double)/100000
                            stockQuote.ttmEPS = stats["ttmEPS"] != nil ? stats["ttmEPS"] as! Double : 0;
                            stockQuote.dividendRate = stats["dividendRate"] as! Double
                            stockQuote.dividend = stats["dividendYield"] as! Double
                            stockQuotes.append(stockQuote)
                        }
                    }
                    
                }
                completion(stockQuotes)
            }
            task.resume()
        }
    }
    
    func fetchStocksChartData(stockSymbol:String, type:chartType, completion:@escaping ([String:Double]) -> Void){
        performQueue.async {
            var chartAPI = "stock/" + stockSymbol
            var timeKey:String = "data"
            var priceKey:String = "open"
            switch type {
            case .OneDay:
                chartAPI += "/chart/1d"
                timeKey = "minute"
                priceKey = "average"
                break
            case .FiveDays:
                chartAPI += "/chart/5d"
                break
            case .OneMonth:
                chartAPI += "/chart/1m"
                break
            case .OneYear:
                chartAPI += "/chart/1y"
                break;
            }
            let stockURL = URL(string: self.baseURL+chartAPI)
            
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
                var chartData = [String:Double]()
                if let arrays = json as? [[String:Any]]{
                    for dict in arrays {
                        if let key = dict[timeKey] as? String, let price = dict[priceKey] as? Double {
                            chartData[key] = price
                        }
                    }
                }
                completion(chartData)
            }
            task.resume()
        }
    }
    
    func fetchStocksFinancialData(stockSymbol:String, completion:@escaping ([Int:[String:Double]]) -> Void){
        performQueue.async {
            let chartAPI = "http://financials.morningstar.com/ajax/exportKR2CSV.html?t=" + stockSymbol
            let stockURL = URL(string: chartAPI)
            let keySet = self.financialParams
            
            let file = try! String(contentsOf: stockURL!, encoding: String.Encoding.utf8)
            let keyStatData = self.cleanupCsvData(data: file)
            let rows = keyStatData.components(separatedBy: "\n")
            var result = [String:[Int:Double]]()    // {params:{year: value}}
            
            for row in rows {
                var columns = self.parseCSVRows(row: row)
                if(columns.count < 2) {
                    //if the company hasn't became public for 4 fours then skip
                    continue;
                }
                let key = self.financialKey(component: columns[0], keySet: keySet!)
                if(key == nil || result[key!] != nil){
                    // the key already fetched once
                    continue
                }
                let date = Date()
                let calendar = Calendar.current
                var year = calendar.component(.year, from: date)
                var oneKeyResult = [Int:Double]()
                var index = columns.count - 1
                var factor = 1.0
                if columns[0].contains("%"){
                    factor = 0.01
                }
                while oneKeyResult.count < 5 {
                    if(index<0){
                        oneKeyResult[year] = -1
                        continue
                    }
                    let value = columns[index].replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
                    if(value.count > 0){
                        oneKeyResult[year] = Double(value)! * factor
                    } else{
                        oneKeyResult[year] = -1
                    }
                    year -= 1
                    index -= 1
                }
                result[key!] = oneKeyResult
            }
            completion(self.reOrganizeResult(temp: result))
        }
    }
    
   // MARK: private methods
    
    private func cleanupCsvData(data:String) -> String{
        var cleanFile = data
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: ",\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\"", with: " ")
        return cleanFile
    }
    
    private func financialKey(component: String, keySet: [String]) -> String? {
        for s in keySet{
            if component.range(of: s) != nil || s.range(of: component) != nil {
                return s
            }
        }
        return nil
    }
    
    // MARK: private methods
    func parseCSVRows(row:String) -> [String]{
        var columns = [String]()
        let primColumns = row.components(separatedBy: ", ")
        for s in primColumns {
            let num = s.filter { $0 == "," }.count
            if(num > 1){
                let split = s.components(separatedBy: ",")
                columns += split
            } else{
                columns.append(s)
            }
        }
        return columns
    }
    
    func reOrganizeResult(temp:[String:[Int:Double]]) -> [Int:[String:Double]]{
        var result = [Int:[String:Double]]()
        for (key, keyResult) in temp{
            for(year, value) in keyResult {
                if(result[year] == nil){
                    result[year] = [String:Double]()
                }
                result[year]![key] = value
            }
        }
        return result
    }
}
