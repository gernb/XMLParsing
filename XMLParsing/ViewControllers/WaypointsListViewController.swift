//
//  WaypointsListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit
import UIKit

final class WaypointsListViewController: ListViewController {
    @IBOutlet private var tableView: UITableView!

    private weak var mapView: MKMapView?
    private var viewModel: WaypointsListViewModel!

    static func create(withMapDisplayDelegate delegate: MapDisplayDelegate, mapView: MKMapView?) -> WaypointsListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WaypointsListViewController") as! WaypointsListViewController
        vc.viewModel = WaypointsListViewModel(delegate: delegate)
        vc.mapView = mapView
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func bindViewModel() {
        super.bindViewModel()
        mapView?.mapViewBindings.waypoints.bind(viewModel.selectedWaypoints)
    }

    override func fileLoaded(_ fileEntity: GpxFileEntity) {
        super.fileLoaded(fileEntity)
        viewModel.updateGpxFileEntity(with: fileEntity)
        tableView?.reloadData()
    }

    private struct Constants {
        static let emptyTableText = NSLocalizedString("No waypoints", comment: "Message shown in list when there are no waypoints")
    }
}

extension WaypointsListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.waypoints.count < 1 {
            tableView.displayEmptyMessage(Constants.emptyTableText)
        }
        return viewModel.waypoints.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let props = viewModel.rowProperties(for: indexPath.row)
        cellView.textLabel?.text = props.title
        cellView.detailTextLabel?.text = props.subtitle
        // Setting `isSelected` doesn't appear to be "enough". The TableView itself needs to "know" that this row is selected.
        if props.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cellView
    }
}

extension WaypointsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectWaypoint(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.deselectWaypoint(at: indexPath.row)
    }
}
