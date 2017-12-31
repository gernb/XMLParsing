//
//  UIView+LoadingView.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

extension UIView {

    var loadingViewIsHidden: Bool {
        get {
            return loadingView == nil
        }
        set {
            newValue ? hideLoadingView() : showLoadingView()
        }
    }

    private var loadingView: LoadingView? {
        return viewWithTag(Constants.tag) as? LoadingView
    }

    func showLoadingView() {
        guard loadingView == nil else { return }
        let view = LoadingView()
        view.tag = Constants.tag
        addSubview(view)
    }

    func hideLoadingView() {
        loadingView?.removeFromSuperview()
    }

    private struct Constants {
        static let tag = 8675309
    }
}
