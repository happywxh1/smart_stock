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

class SmartStockFooterBar: UIView {
    weak var delegate: SmartStockFooterBarDelegate?
    var footerBar : UIToolbar!
    var focusButton:SmartStockFooterBarButtonType
    
    init(delegate:SmartStockFooterBarDelegate) {
        self.delegate = delegate
        focusButton = SmartStockFooterBarButtonType.HomeButton
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.white
        footerBar = UIToolbar()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action:#selector(onHomeButtonTapped))
        let findButton = UIBarButtonItem(title: "Find", style: .plain, target: self, action:#selector(onFindButtonTapped))
        footerBar.setItems([homeButton, findButton], animated: false)
        
        self.addSubview(footerBar)
        footerBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        footerBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        footerBar.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        footerBar.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onHomeButtonTapped() {
        if focusButton == .HomeButton {
            return
        }
        focusButton = .HomeButton
        delegate?.tapFooterBarButton(type: SmartStockFooterBarButtonType.HomeButton)
    }
    
    @objc func onFindButtonTapped() {
        if focusButton == .FindButton {
            return
        }
        focusButton = .FindButton
        delegate?.tapFooterBarButton(type: SmartStockFooterBarButtonType.FindButton)
    }
}
