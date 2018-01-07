//
//  TracksListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit

class TracksListViewController: UIViewController {

    static func create() -> TracksListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TracksListViewController") as! TracksListViewController
        return vc
    }
}
