//
//  XHSmartStockMainViewController.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/23/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

enum SmartStockCurrentFocusView:Int {
    case HomeStockView = 0
    case FindSearchView
}
let smartStockFooterBarHight = 50

class XHSmartStockMainViewController: UIViewController, SmartStockFooterBarDelegate {
    var footerBar : XHSmartStockFooterBar!
    var stockListViewController: XHStockListViewController!
    var smartFindViewController: SmartStockFindViewController!
    var focusView:SmartStockCurrentFocusView
    var containerView:UIView!
    
    init() {
        focusView = SmartStockCurrentFocusView.HomeStockView
        super.init(nibName: nil, bundle: nil)
        footerBar = XHSmartStockFooterBar.init(delegate: self)
        stockListViewController = XHStockListViewController()
        smartFindViewController = SmartStockFindViewController()
        containerView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.setupNavigationFooterBar()
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        self.view.addSubview(footerBar)
        footerBar.snp.makeConstraints { (make)->Void in
            make.right.left.bottom.equalTo(self.view)
            make.height.equalTo(smartStockFooterBarHight)
        }
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make)->Void in
            make.right.left.top.equalTo(self.view)
            make.bottom.equalTo(footerBar.snp.top)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.presentViewController()
    }
    
    //MARK: SmartStockFooterBarDelegate
    func tapFooterBarButton(type: SmartStockFooterBarButtonType) {
        if(type.rawValue == self.focusView.rawValue){
            return;
        }
        self.focusView = type == SmartStockFooterBarButtonType.HomeButton ? SmartStockCurrentFocusView.HomeStockView : SmartStockCurrentFocusView.FindSearchView
    }
    
    //MARK: Helper
    private func presentViewController() {
        if(self.focusView == SmartStockCurrentFocusView.HomeStockView){
            stockListViewController.navigationController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(stockListViewController, animated: false)
            //self.navigationController?.present(stockListViewController, animated: false, completion: nil)
        } else if(self.focusView == SmartStockCurrentFocusView.FindSearchView){
            smartFindViewController.navigationController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(smartFindViewController, animated: false)
            //self.navigationController?.present(smartFindViewController, animated: false, completion: nil)
        }
    }
    
    private func setupNavigationFooterBar() {
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action:#selector(onHomeButtonTapped))
        let findButton = UIBarButtonItem(title: "Find", style: .plain, target: self, action:#selector(onFindButtonTapped))
        self.setToolbarItems([homeButton, findButton], animated: false)
    }
    
    @objc func onHomeButtonTapped() {
        if(focusView != SmartStockCurrentFocusView.HomeStockView){
            self.focusView = SmartStockCurrentFocusView.HomeStockView
            presentViewController()
        }
    }
    
    @objc func onFindButtonTapped() {
        if(focusView != SmartStockCurrentFocusView.FindSearchView){
            self.focusView = SmartStockCurrentFocusView.FindSearchView
            presentViewController()
        }
    }
}
