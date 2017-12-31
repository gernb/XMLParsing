//
//  UIViewController+Binding.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

public extension UIViewController {

    private static var handle: UInt8 = 0
    /// The `ViewControllerBindings` exposed by this control.
    public var viewControllerBindings: ViewControllerBindings {
        if let b = objc_getAssociatedObject(self, &UIViewController.handle) as? ViewControllerBindings {
            return b
        }
        else {
            let b = ViewControllerBindings(self)
            objc_setAssociatedObject(self, &UIViewController.handle, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }

    /// A collection of `Binding` instances for `UIViewController`.
    public class ViewControllerBindings {
        private unowned let vc: UIViewController

        /// `Binding` for the `title` property.
        private (set) public lazy var title: Binding<String> =
            Binding<String>(setValue: { [unowned self] v in self.vc.title = v },
                            getValue: { [unowned self] in return self.vc.title })

        public init(_ vc: UIViewController) {
            self.vc = vc
        }
    }
}

