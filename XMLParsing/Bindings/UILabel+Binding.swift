//
//  UILabel+Binding.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

public extension UILabel {

    private static var handle: UInt8 = 0
    /// The `LabelBindings` exposed by this control.
    public var labelBindings: LabelBindings {
        if let b = objc_getAssociatedObject(self, &UILabel.handle) as? LabelBindings {
            return b
        }
        else {
            let b = LabelBindings(self)
            objc_setAssociatedObject(self, &UILabel.handle, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }

    /// A collection of `Binding` instances for `UILabel`.
    public class LabelBindings: UIView.ViewBindings {
        private unowned let label: UILabel

        /// `Binding` for the `text` property.
        private (set) public lazy var text: Binding<String> =
            Binding<String>(setValue: { [unowned self] v in self.label.text = v },
                            getValue: { [unowned self] in return self.label.text })

        /// `Binding` for the `font` property.
        private (set) public lazy var font: Binding<UIFont> =
            Binding<UIFont>(setValue: { [unowned self] v in self.label.font = v },
                            getValue: { [unowned self] in return self.label.font })

        /// `Binding` for the `attributedText` property.
        private (set) public lazy var attributedText: Binding<NSAttributedString> =
            Binding<NSAttributedString>(setValue: { [unowned self] v in self.label.attributedText = v },
                                        getValue: { [unowned self] in return self.label.attributedText })

        public init(_ label: UILabel) {
            self.label = label
            super.init(label)
        }
    }
}
