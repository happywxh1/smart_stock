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
        NSLayoutConstraint.activate([
            keyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            keyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            keyLabel.topAnchor.constraint(equalTo: self.topAnchor),
            keyLabel.widthAnchor.constraint(equalToConstant: 50.0)
        ])

        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            valueLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            valueLabel.topAnchor.constraint(equalTo: self.topAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 50.0)
        ])
    }
}
