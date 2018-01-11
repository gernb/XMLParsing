//
//  TracksListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit
import UIKit

final class TracksListViewController: ListViewController {
    @IBOutlet private var tableView: UITableView!

    private weak var mapView: MKMapView?
    private var viewModel: TracksListViewModel!

    static func create(withMapDisplayDelegate delegate: MapDisplayDelegate, gpxFileProvider: GpxFileProviding, mapView: MKMapView?) -> TracksListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TracksListViewController") as! TracksListViewController
        vc.viewModel = TracksListViewModel(delegate: delegate, gpxFileProvider: gpxFileProvider)
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
        mapView?.mapViewBindings.gpxTracks.bind(viewModel.selectedTracks)
    }

    override func fileLoaded(_ fileEntity: GpxFileEntity) {
        super.fileLoaded(fileEntity)
        viewModel.updateGpxFileEntity(with: fileEntity)
        tableView?.reloadData()
    }

    private struct Constants {
        static let emptyTableText = NSLocalizedString("No tracks", comment: "Message shown in list when there are no tracks")
    }
}

extension TracksListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.tracks.count < 1 {
            tableView.displayEmptyMessage(Constants.emptyTableText)
        }
        return viewModel.tracks.count
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

extension TracksListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTrack(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.deselectTrack(at: indexPath.row)
    }
}
