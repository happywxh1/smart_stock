//
//  StockDetailViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 2/25/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit
import Charts

let navigationBarHight = 50
let priceChartViewHeight = 200
let statViewCellReuseIdentifier = "statisticsTableViewCell"

class StockDetailViewController: UIViewController, UINavigationBarDelegate, UIBarPositioningDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var stockQuote:stockCurrentQuoteInfo!
    var chartView: LineChartView!
    var navBar: UINavigationBar!
    var xTime = [String]()
    let networkManager = XHStockInfoDownloader.sharedInstance
    
    var infoTableView : UITableView!
    var statistics: Dictionary<String, String>!
    
    init(stockQuote:stockCurrentQuoteInfo) {
        super.init(nibName: nil, bundle: nil)
        self.stockQuote = stockQuote
        self.parseStatistics()
        
        chartView = LineChartView()
        self.view.addSubview(chartView);
        
        chartView.snp.makeConstraints { (make)->Void in
            make.right.left.equalTo(self.view)
            make.top.equalTo(navBar.snp.bottom)
            make.height.equalTo(priceChartViewHeight)
        };
        
        infoTableView = UITableView.init(frame: CGRect.zero)
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: statViewCellReuseIdentifier)
        self.view.addSubview(infoTableView);
        
        infoTableView.snp.makeConstraints { (make)->Void in
            make.right.left.equalTo(self.view)
            make.top.equalTo(chartView.snp.bottom)
            make.height.equalTo(200)
        };
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let plotType = chartType.OneDay
        weak var weakSelf = self
        networkManager.fetchStocksChartData(stockSymbol: stockQuote.symbol!, type:plotType) { (chartData) in
            DispatchQueue.main.async {
                weakSelf!.plotChartGraph(data: chartData)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        view.backgroundColor = .white
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.xAxis.enabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statistics.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: statViewCellReuseIdentifier) as! StatisticsTableViewCell
        cell.setKeyValue(key: Array(statistics.keys)[indexPath.row], value: Array(statistics.values)[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(30)
    }
    
    //MARK: Private methods
    
    func parseStatistics() {
        var info = Dictionary<String, String>.init()
        info["Previous Close"] = String(format: "%.02f",stockQuote.previousClose);
        info["Open"] = String(format: "%.02f",stockQuote.todayOpen)
        info["Day's Range"] = String(format: "%.02f,%0.02f",stockQuote.todayLow, stockQuote.todayHigh)
        info["52 week Range"] = String(format: "%.02f,%0.02f",stockQuote.week52Low, stockQuote.week52High)
        info["Volume"] = String(format: "%.02f M",stockQuote.latestVolume);
        info["Market Cap"] = String(format: "%.02f M",stockQuote.marketCap);
        info["EPS (TTM)"] = String(format: "%.02f M",stockQuote.ttmEPS)
        info["PE Ratio"] = String(format: "%.02f M",stockQuote.peRatio)
        info["Dividend"] = String(format: "%.02f M",stockQuote.dividend)
        
        self.statistics = info
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBarFrame = CGRect.init(x: 0, y: 20, width: Int(screenSize.width), height: navigationBarHight)
        navBar = UINavigationBar(frame:navBarFrame)
        navBar.delegate = self
        let navItem = UINavigationItem(title:stockQuote.companyName!)
        let backButton = UIBarButtonItem.init(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(back))
        navItem.leftBarButtonItem = backButton
        
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func plotChartGraph(data:[String:Double]){
        var yValue = [Double]()
        
        for(x, y) in data{
            xTime.append(x)
            yValue.append(y)
        }
        var values = [ChartDataEntry]()
        for  i in 0..<xTime.count {
            if(yValue[i]>0){
                values.append(ChartDataEntry(x: Double(i), y: yValue[i]))
            }
        }
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        
        set1.drawIconsEnabled = false
        set1.drawCirclesEnabled = false
        
        set1.setColor(.red)
        set1.setCircleColor(.white)
        set1.lineWidth = 1
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }
}

extension StockDetailViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xTime[Int(value)]
    }
}
