//
//  XHStockInfoDownloader.swift
//  Smart Stock
//
//  Created by Xiaohong Wang on 7/30/17.
//  Copyright © 2017 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class XHStockInfoDownloader: NSObject {
    //to fetch stock information from yahoo finance API
    
    class func fetchStockKeyRatio(stockSymbol:String){
         let stockURL = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22\(stockSymbol)%22)&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&format=json"
        
        let request = URLRequest(url: URL(string: stockURL)!)
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
            print(json)
        }
        task.resume()
    }
}
