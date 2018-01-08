//
//  AllListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit

class AllListViewController: ListViewController {

    static func create() -> AllListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllListViewController") as! AllListViewController
        return vc
    }
}
