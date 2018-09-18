//
//  StatisticsTableViewCell.swift
//  
//
//  Created by Xiaohong Wang on 9/3/18.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    let keyLabel = UILabel()
    let valueLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setKeyValue(key:String, value:String) -> () {
        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor : UIColor.black,
            .font : UIFont.boldSystemFont(ofSize: 10)
        ]
        keyLabel.attributedText = NSAttributedString(string: key, attributes: attributes)
        valueLabel.attributedText = NSAttributedString(string: value, attributes: attributes)
    }
    
    //MARK: Private
    fileprivate func setupLayout() {
        keyLabel.textAlignment = .left
        keyLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(keyLabel)
        keyLabel.snp.makeConstraints { (make)->Void in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self.snp.left).offset(8)
            make.width.equalTo(50)
        }
        
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make)->Void in
            make.top.bottom.equalTo(self)
            make.right.equalTo(self).offset(-4)
            make.width.equalTo(50)
        }
    }
}
