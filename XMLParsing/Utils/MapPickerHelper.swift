//
//  MapPickerHelper.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapPickerHelper: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var rowSelected: ((MKMapType) -> Void)?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MKMapType.all.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MKMapType.all[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rowSelected?(MKMapType.all[row])
    }
}
