//
//  XHSmartStockFooterBar.swift
//  SmartStock
//
//  Created by Xiaohong Wang on 9/23/18.
//  Copyright © 2018 project.stock.com.xiaohong. All rights reserved.
//

import UIKit

enum SmartStockFooterBarButtonType:Int {
    case HomeButton = 0
    case FindButton
}

protocol SmartStockFooterBarDelegate :class {
    func tapFooterBarButton(type:SmartStockFooterBarButtonType)
}

class XHSmartStockFooterBar: UIView {
    weak var delegate: SmartStockFooterBarDelegate?
    var footerBar : UIToolbar!
    
    init(delegate:SmartStockFooterBarDelegate) {
        self.delegate = delegate
        footerBar = UIToolbar()
        super.init(frame: CGRect.zero)
        
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action:#selector(onHomeButtonTapped))
        let findButton = UIBarButtonItem(title: "Find", style: .plain, target: self, action:#selector(onFindButtonTapped))
        footerBar.setItems([homeButton, findButton], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onHomeButtonTapped() {
        delegate?.tapFooterBarButton(type: SmartStockFooterBarButtonType.HomeButton)
    }
    
    @objc func onFindButtonTapped() {
        delegate?.tapFooterBarButton(type: SmartStockFooterBarButtonType.FindButton)
    }
}
