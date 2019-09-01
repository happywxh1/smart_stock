//
//  XHSmartStockMainViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/23/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

let smartStockFooterBarHight = 50

class SmartStockMainViewController: UIViewController, SmartStockFooterBarDelegate {
    var footerBar : SmartStockFooterBar!
    var stockListViewController: XHStockListViewController!
    var smartFindViewController: SmartStockFindViewController!
    var containerView:UIView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        stockListViewController = XHStockListViewController()
        self.addChildViewController(stockListViewController)
        smartFindViewController = SmartStockFindViewController()
        self.addChildViewController(smartFindViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        footerBar = SmartStockFooterBar(delegate: self)
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(footerBar)
        NSLayoutConstraint.activate([
            footerBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            footerBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            footerBar.heightAnchor.constraint(equalToConstant: 50.0)])
   
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: footerBar.topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch footerBar.focusButton {
        case .HomeButton:
            stockListViewController.view.frame = self.containerView.frame
            self.containerView.addSubview(stockListViewController.view)
        case .FindButton:
            smartFindViewController.view.frame = self.containerView.frame
            self.containerView.addSubview(smartFindViewController.view)
        }
    }
    
    //MARK: SmartStockFooterBarDelegate
    func tapFooterBarButton(type: SmartStockFooterBarButtonType) {
        switch type {
        case SmartStockFooterBarButtonType.HomeButton:
            changeControllerFromOldController(oldVC: smartFindViewController, newVC: stockListViewController)
            break
        case SmartStockFooterBarButtonType.FindButton:
            changeControllerFromOldController(oldVC: stockListViewController, newVC: smartFindViewController)
            break
        }
    }

    //MARK: Switch view controller
    @objc func changeControllerFromOldController(oldVC: UIViewController, newVC:UIViewController){
        oldVC.willMove(toParentViewController: nil)
        self.addChildViewController(newVC)
        self.transition(from: oldVC, to: newVC, duration: 0.2, options: UIViewAnimationOptions.curveEaseOut,
                        animations: {
                            newVC.view.frame = self.containerView.frame;
        },
                        completion: { (success) in
                            oldVC.removeFromParentViewController()
                            newVC.didMove(toParentViewController: self)
        })
    }
}
