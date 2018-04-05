//
//  StockDetailViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 2/25/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class StockDetailViewController: UIViewController {
    var stockCurrentQuote:stockCurrentQuoteInfo
    
    init(stockQuote:stockCurrentQuoteInfo) {
        self.stockCurrentQuote = stockQuote
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        view.backgroundColor = .yellow
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBarFrame = CGRect.init(x: 0, y: 0, width: screenSize.width, height: 40)
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
}
