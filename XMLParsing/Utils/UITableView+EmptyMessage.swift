//
//  UITableView+EmptyMessage.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/8/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit

extension UITableView {

    func displayEmptyMessage(_ message: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.sizeToFit()

        backgroundView = label
        separatorStyle = .none
    }

    func removeEmptyMessage() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
