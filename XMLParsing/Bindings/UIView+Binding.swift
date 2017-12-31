//
//  UIView+Binding.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

public extension UIView {

    private static var handle: UInt8 = 0
    /// The `ViewBindings` exposed by this control.
    public var viewBindings: ViewBindings {
        if let b = objc_getAssociatedObject(self, &UIView.handle) as? ViewBindings {
            return b
        }
        else {
            let b = ViewBindings(self)
            objc_setAssociatedObject(self, &UIView.handle, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }

    /// A collection of `Binding` instances for `UIView`.
    public class ViewBindings {
        private unowned let view: UIView

        /// `Binding` for the `isHidden` property.
        private (set) public lazy var isHidden: Binding<Bool> =
            Binding<Bool>(setValue: { [unowned self] v in self.view.isHidden = v },
                          getValue: { [unowned self] in return self.view.isHidden })

        /// `Binding` for the `loadingViewIsHidden` property.
        private (set) public lazy var loadingViewIsHidden: Binding<Bool> =
            Binding<Bool>(setValue: { [unowned self] v in self.view.loadingViewIsHidden = v },
                          getValue: { [unowned self] in return self.view.loadingViewIsHidden })

        public init(_ view: UIView) {
            self.view = view
        }
    }
}
