//
//  XHSmartStockMainViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/23/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

let smartStockFooterBarHight = 50

class SmartStockMainViewController: UITabBarController {
    var footerBar : SmartStockFooterBar!
    var stockListViewController: XHStockListViewController!
    var smartFindViewController: SmartStockFindViewController!
    var containerView:UIView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let mainStockVC = UINavigationController(rootViewController: XHStockListViewController())
        mainStockVC.tabBarItem.title = "Home"
        self.addChild(mainStockVC)
        
        let smartFindVC = UINavigationController(rootViewController: SmartStockFindViewController())
        smartFindVC.tabBarItem.title = "Find"
        self.addChild(smartFindVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
/*
    //MARK: Switch view controller
    @objc func changeControllerFromOldController(oldVC: UIViewController, newVC:UIViewController){
        oldVC.willMove(toParent: nil)
        self.addChild(newVC)
        self.transition(from: oldVC, to: newVC, duration: 0.2, options: UIView.AnimationOptions.curveEaseOut,
                        animations: {
                            newVC.view.frame = self.containerView.frame;
        },
                        completion: { (success) in
                            oldVC.removeFromParent()
                            newVC.didMove(toParent: self)
        })
    }
 */
}
