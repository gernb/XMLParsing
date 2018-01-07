//
//  WaypointsListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit

class WaypointsListViewController: UIViewController {

    static func create() -> WaypointsListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WaypointsListViewController") as! WaypointsListViewController
        return vc
    }
}
