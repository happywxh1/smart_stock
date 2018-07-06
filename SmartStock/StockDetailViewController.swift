//
//  StockDetailViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 2/25/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit
import Charts

let navigationBarHight = 60

class StockDetailViewController: UIViewController {
    var stockCurrentQuote:stockCurrentQuoteInfo
    var plotType = chartType.OneDay
    var chartView: LineChartView!
    var xTime = [String]()
    
    init(stockQuote:stockCurrentQuoteInfo) {
        self.stockCurrentQuote = stockQuote
        chartView = LineChartView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        weak var weakSelf = self
        /*
        XHStockInfoDownloader.fetchStocksChartData(stockSymbol: stockCurrentQuote.symbol!, type:plotType) { (chartData) in
            weakSelf!.plotChartGraph(data: chartData)
        }*/
        XHStockInfoDownloader.fetchStocksFinancialData(stockSymbol: stockCurrentQuote.symbol!, type:plotType) {(chartData) in
            print(chartData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        view.backgroundColor = .white
        
        self.view.addSubview(chartView);
        
        chartView.snp.makeConstraints { (make)->Void in
            make.right.left.equalTo(self.view)
            make.top.equalTo(self.view).offset(navigationBarHight)
            make.height.equalTo(300)
        };
        
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
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBarFrame = CGRect.init(x: 0, y: 0, width: Int(screenSize.width), height: navigationBarHight)
        let navBar = UINavigationBar(frame:navBarFrame)
        let navItem = UINavigationItem(title:"")
        let backButton = UIBarButtonItem.init(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(back))
        navItem.leftBarButtonItem = backButton
        
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    func back(){
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
