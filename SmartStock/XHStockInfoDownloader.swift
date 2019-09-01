//
//  XHStockInfoDownloader.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/30/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class StockKeyStats{
    var symbol: String
    var companyName: String?
    var peRatio: Double!
    var week52High: Double!
    var week52Low: Double!
    var ttmEPS: Double!
    var dividend: Double!
    var dividendRate: Double! //for the percentage
    
    required init(symbol: String){
        self.symbol = symbol;
    }
}

class StockCurrentQuote{
    var symbol: String
    var latestPrice:Double!
    var previousClose: Double!
    var marketCap: Double!
    var latestVolume: Double!   //in the unit of Million
    
    required init(symbol: String){
        self.symbol = symbol
    }
}

class StockPriceDetails{
    var symbol: String
    var chartData: [String:Double]
    var todayHigh: Double!
    var todayLow: Double!
    var todayOpen: Double!
    
    required init(symbol: String) {
        self.symbol = symbol
        chartData = [String:Double]()
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
    let apiKey = "pk_9fef3fe9c23e4e4da7f45aef2ce85f38"
    let alphaApiKey = "UAI3PPF7GSHSOMW5"
    let baseURL = "https://cloud.iexapis.com/"
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

    func fetchStocksCurrentPrices_Deprecate(stockSymbols:[String], completion:@escaping (([StockCurrentQuote])) -> Void){
        let url = "https://www.alphavantage.co/query?function=BATCH_STOCK_QUOTES&symbols="
            + stockSymbols.joined(separator: ",")
            + "&apikey=" + alphaApiKey + "&datatype=json"
        
        let stockURL = URL(string: url)
        
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
            var prices = [StockCurrentQuote]()
            if let dict = json as? [String:Any], let results = dict["Stock Quotes"] as? [Any] {
                for case let price as [String:Any] in results{
                    if let symbol = price["1. symbol"] as? String, let p = price["2. price"] as? String{
                        prices.append(StockCurrentQuote(symbol: symbol, price: Double(p)!))
                    }
                }
            }
            completion(prices)
        }
        task.resume()
    }
 */
    
    func fetchQuoteAndStatsOfStocks(stockSymbols:[String], completion:@escaping (([String: StockKeyStats]), ([String: StockCurrentQuote])) -> Void){
        var stocksStats = [String: StockKeyStats]()
        var stocksQuote = [String: StockCurrentQuote]()
        let dispatchGroup = DispatchGroup()

        for symb in stockSymbols{
            dispatchGroup.enter()
            dispatchGroup.enter()
            self._fetchKeyStatsOfStock(stockSymbol: symb) { (stockStats) in
                dispatchGroup.leave()
                stocksStats[symb] = stockStats
            }
            self._fetchQuoteOfStock(stockSymbol: symb) { (stockQuote) in
                dispatchGroup.leave()
                stocksQuote[symb] = stockQuote
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(stocksStats, stocksQuote)
        }
    }
    
    func _fetchKeyStatsOfStock(stockSymbol:String, completion:@escaping ((StockKeyStats)) -> Void){
        let endpoint = "stable/stock/\(stockSymbol)/stats"
        let statsURL = URL(string: self.constUrlForEndpoint(endpoint: endpoint))
        let request = URLRequest(url: statsURL!)
        performQueue.async {
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
                let stockStats = StockKeyStats(symbol: stockSymbol)
                if let dict = json as? [String:Any]{
                    stockStats.companyName = dict["companyName"] as? String
                    stockStats.week52Low = dict["week52low"] as! Double
                    stockStats.week52High = dict["week52high"] as! Double
                    stockStats.peRatio = dict["peRatio"] as! Double
                    stockStats.ttmEPS = dict["ttmEPS"] != nil ? dict["ttmEPS"] as! Double : 0;
                    stockStats.dividend = dict["dividendYield"] is NSNull ? 0.0: dict["dividendYield"] as! Double
                }
                completion(stockStats)
            }
            task.resume()
        }
    }
    
    func _fetchQuoteOfStock(stockSymbol:String, completion:@escaping ((StockCurrentQuote)) -> Void){
        let endpoint = "stable/stock/\(stockSymbol)/quote"
        let statsURL = URL(string: self.constUrlForEndpoint(endpoint: endpoint))
        let request = URLRequest(url: statsURL!)
        performQueue.async {
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
                let stockQuote = StockCurrentQuote(symbol: stockSymbol)
                if let dict = json as? [String:Any]{
                    stockQuote.latestPrice = dict["latestPrice"] as! Double
                    stockQuote.previousClose = dict["previousClose"] as! Double
                    stockQuote.marketCap = self._getMarketCap(quote: dict)
                    stockQuote.latestVolume = (dict["latestVolume"] as! Double)/100000.0
                }
                completion(stockQuote)
            }
            task.resume()
        }
    }
    
    func fetchStocksChartData(stockSymbol:String, type:chartType, completion:@escaping (StockPriceDetails) -> Void){
        performQueue.async {
            var chartAPI = "stable/stock/" + stockSymbol
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
            let stockURL = URL(string: self.constUrlForEndpoint(endpoint: chartAPI))
            
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
                let priceDetails = StockPriceDetails(symbol: stockSymbol)
                if let arrays = json as? [[String:Any]]{
                    for dict in arrays {
                        if let key = dict[timeKey] as? String, let price = dict[priceKey] as? Double {
                            priceDetails.chartData[key] = price
                        }
                    }
                    let latest = arrays.last
                    priceDetails.todayHigh = latest!["high"] as! Double
                    priceDetails.todayLow = latest!["low"] as! Double
                    priceDetails.todayOpen = latest!["open"] as! Double
                }
                completion(priceDetails)
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
    
    func constUrlForEndpoint(endpoint:String) -> String{
        var separator = "?"
        if endpoint.contains("?"){
            separator = "&"
        }
        return baseURL + endpoint + separator + "token=" + apiKey;
    }
    
    func _getMarketCap(quote:[String:Any]) -> Double {
        if !(quote["marketCap"] is NSNull) {
            return (quote["marketCap"] as! Double) / 1000000.0
        }
        if let price = quote["latestPrice"] as? Double, let shares = quote["float"] as? Double {
            return price * shares / 1000000.0
        }
        return 0.0
    }
}
