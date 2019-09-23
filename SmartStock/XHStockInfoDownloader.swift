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
        self.symbol = symbol
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

enum chartType{
    case OneDay
    case FiveDays
    case OneMonth
    case OneYear
}

class XHStockInfoDownloader: NSObject {
    //to fetch stock information from finance API
    let apiKey = "pk_9fef3fe9c23e4e4da7f45aef2ce85f38"
    let baseURL = "https://cloud.iexapis.com/"
    var financialParams: Array<String>?
    let performQueue = DispatchQueue(label: "stockInfoDownloader", attributes: .concurrent)
    let downloadManager = DownloadManager()
    
    override init() {
        super.init()
        self.financialParams = StockFinancialParams.allFinancialParams()
    }
    
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

        self.downloadManager.queueDownload(statsURL!, completionHandler: { (data, response, error) in
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
        })
    }
    
    func _fetchQuoteOfStock(stockSymbol:String, completion:@escaping ((StockCurrentQuote)) -> Void){
        let endpoint = "stable/stock/\(stockSymbol)/quote"
        let quoteURL = URL(string: self.constUrlForEndpoint(endpoint: endpoint))
        
        self.downloadManager.queueDownload(quoteURL!, completionHandler: { (data, response, error) in
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
        })
    }
    
    func fetchStocksChartData(stockSymbol:String, type:chartType, completion:@escaping (StockPriceDetails) -> Void){
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
        
        self.downloadManager.queueDownload(stockURL!, completionHandler: { (data, response, error) in
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
        })
    }
    
    func fetchFinancialsOfStock(stockSymbol:String, completion:@escaping (([StockFinancial])) -> Void){
        let baseUrl = "https://financialmodelingprep.com/api/v3/"
        let incomeUrl = URL(string: baseUrl +  "financials/income-statement/\(stockSymbol)")
        //let cashFlowUrl = URL(string: baseUrl +  "cash-flow-statement/\(stockSymbol)")
        
        self.downloadManager.queueDownload(incomeUrl!, completionHandler: { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            var financials = [StockFinancial]()
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let all = json as? [String:Any], let arrays = all["financials"] as? [[String:Any]]{
                for dict in arrays {
                    let date =  dict["date"] as! String
                    let financial = StockFinancial(symbol: stockSymbol, year: Int16(date.prefix(4))!)
                    financial.earningPerShare = dict["EPS"] as! Double
                    financial.revenue = dict["Revenue"] as! Double
                    financial.netIncome = dict["Net Income"] as! Double
                    financial.grossMargin = dict["Gross Margin"] as! Double
                    
                    let cashFlowMargin = dict["Free Cash Flow margin"] as! Double
                    financial.freeCashFlow = cashFlowMargin * financial.revenue

                    financials.append(financial)
                    if financials.count > 3 {
                        break
                    }
                }
            }
            completion(financials)
        })
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
