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
    
    var stockQuote:StockCurrentQuote!
    var stockStats:StockKeyStats!
    var chartView: LineChartView!
    var navBar: UINavigationBar!
    var xTime = [String]()
    let networkManager = XHStockInfoDownloader()
    
    var infoTableView : UITableView!
    var statistics: Dictionary<String, String>!
    
    init(stockQuote:StockCurrentQuote, stockStats:StockKeyStats) {
        super.init(nibName: nil, bundle: nil)
        self.stockQuote = stockQuote
        self.stockStats = stockStats
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
            make.bottom.equalTo(self.view)
        };
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let plotType = chartType.OneDay
        weak var weakSelf = self
        networkManager.fetchStocksChartData(stockSymbol: stockQuote.symbol, type:plotType) { (priceDetails) in
            DispatchQueue.main.async {
                weakSelf!.chartView.leftAxis.axisMinimum = priceDetails.todayLow - 5*(priceDetails.todayHigh -  priceDetails.todayLow)
                weakSelf!.plotChartGraph(data: priceDetails.chartData)
                weakSelf!.statistics["Open"] = String(format: "%.02f",priceDetails.todayOpen)
                weakSelf!.statistics["Day Range"] = String(format: "%.02f,%0.02f",priceDetails.todayLow, priceDetails.todayHigh)
                weakSelf!.infoTableView.reloadData()
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
        return CGFloat(40)
    }
    
    //MARK: Private methods
    
    func parseStatistics() {
        var info = Dictionary<String, String>.init()
        info["Previous Close"] = String(format: "%.02f",stockQuote.previousClose);
        info["Volume"] = String(format: "%.02f M",stockQuote.latestVolume);
        
        info["52 week Range"] = String(format: "%.02f,%0.02f",stockStats.week52Low, stockStats.week52High)
        info["Market Cap"] = String(format: "%.02f M",stockQuote.marketCap);
        info["EPS (TTM)"] = String(format: "%.02f M",stockStats.ttmEPS)
        info["PE Ratio"] = String(format: "%.02f M",stockStats.peRatio)
        info["Dividend"] = String(format: "%.02f M",stockStats.dividend)
        self.statistics = info
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBarFrame = CGRect.init(x: 0, y: 20, width: Int(screenSize.width), height: navigationBarHight)
        navBar = UINavigationBar(frame:navBarFrame)
        navBar.delegate = self
        let navItem = UINavigationItem(title:stockStats.companyName!)
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
        set1.fill = Fill(linearGradient: gradient, angle: 90)
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
