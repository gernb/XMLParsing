//
//  RoutesListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit

class RoutesListViewController: ListViewController {

    static func create() -> RoutesListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutesListViewController") as! RoutesListViewController
        return vc
    }
}
