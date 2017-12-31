//
//  LoadingView.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

final class LoadingView: UIView {

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        frame = superview.frame
        activityIndicator.frame = bounds
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}
