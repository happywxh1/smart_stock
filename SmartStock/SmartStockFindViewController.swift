//
//  SmartStockFindViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/23/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

class SmartStockFindViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
