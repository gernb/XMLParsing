//
//  AllListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit
import UIKit

final class AllListViewController: ListViewController {
    @IBOutlet private var tableView: UITableView!

    private weak var mapView: MKMapView?
    private var viewModel: AllListViewModel!

    static func create(withMapDisplayDelegate delegate: MapDisplayDelegate, gpxFileProvider: GpxFileProviding, mapView: MKMapView?) -> AllListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllListViewController") as! AllListViewController
        vc.viewModel = AllListViewModel(delegate: delegate, gpxFileProvider: gpxFileProvider)
        vc.mapView = mapView
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        updateTableViewTotals()
    }

    override func bindViewModel() {
        super.bindViewModel()
        mapView?.mapViewBindings.gpxPaths.bind(viewModel.selectedPaths)
        mapView?.mapViewBindings.waypoints.bind(viewModel.selectedWaypoints)
    }

    override func fileLoaded(_ fileEntity: GpxFileEntity) {
        super.fileLoaded(fileEntity)
        viewModel.updateGpxFileEntity(with: fileEntity)
        tableView?.reloadData()
        updateTableViewTotals()
    }

    private func updateTableViewTotals() {
        guard let tableView = tableView else { return }
        var total = 0
        for section in AllListViewModel.Section.all {
            total += viewModel.numberOfRows(in: section)
        }
        if total < 1 {
            tableView.displayEmptyMessage(Constants.emptyTableText)
        } else {
            tableView.removeEmptyMessage()
        }
    }

    private struct Constants {
        static let emptyTableText = NSLocalizedString("Hhmmm, this file appears to be empty", comment: "Message shown in list when there are no tracks, routes, or waypoints")
    }
}

extension AllListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return AllListViewModel.Section.all.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModelSection = AllListViewModel.Section(rawValue: section) else {
            Logger.error(category: .view, "Unexpected section number: \(section)")
            fatalError("Unexpected section number: \(section)")
        }
        return viewModel.numberOfRows(in: viewModelSection)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModelSection = AllListViewModel.Section(rawValue: section) else {
            Logger.error(category: .view, "Unexpected section number: \(section)")
            fatalError("Unexpected section number: \(section)")
        }
        if viewModel.numberOfRows(in: viewModelSection) > 0 {
            return viewModelSection.title
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let props = viewModel.rowProperties(for: indexPath) else {
            Logger.error(category: .view, "No row properties for: \(indexPath)")
            return cellView
        }
        cellView.textLabel?.text = props.title
        cellView.detailTextLabel?.text = props.subtitle
        // Setting `isSelected` doesn't appear to be "enough". The TableView itself needs to "know" that this row is selected.
        if props.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cellView
    }
}

extension AllListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.deselectRow(at: indexPath)
    }
}
