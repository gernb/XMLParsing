//
//  PickerButton.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

class PickerButton: UITextField {

    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }

    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
