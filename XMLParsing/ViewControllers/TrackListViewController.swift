//
//  TrackListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit
import MapKit

class TrackListViewController: UIViewController {
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapTypeButton: PickerButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tabBar: UITabBar!

    private var viewModel: TrackListViewModel!
    private let mapPickerHelper = MapPickerHelper()

    static func create(withFile file: GpxFileEntity) -> TrackListViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackListViewController") as! TrackListViewController
        vc.viewModel = TrackListViewModel(file: file, moc: AppDelegate.shared.coreDataContainer.viewContext, delegate: vc)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapViewBindings.gpxTracks.bind(viewModel.selectedTracks)
        mapView.mapViewBindings.gpxRoutes.bind(viewModel.selectedRoutes)
        mapView.mapViewBindings.waypoints.bind(viewModel.selectedWaypoints)

        mapTypeButton.inputView = {
            mapPickerHelper.rowSelected = { [weak self] mapType in
                guard let strongSelf = self else { return }
                strongSelf.dismissKeyboard()
                AppDelegate.shared.currentMapType = mapType
                strongSelf.setMapType()
            }
            let pickerView = UIPickerView()
            pickerView.showsSelectionIndicator = true
            pickerView.dataSource = mapPickerHelper
            pickerView.delegate = mapPickerHelper
            pickerView.selectRow(MKMapType.all.index(of: AppDelegate.shared.currentMapType)!, inComponent: 0, animated: false)
            return pickerView
        }()
        setMapType()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        tableView.dataSource = self
        tableView.delegate = self

        tabBar.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            for tab in tabBar.items! {
                tab.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
            }
        }

        viewControllerBindings.title.bind(viewModel.title)
        view.viewBindings.loadingViewIsHidden.bind(viewModel.loadingViewIsHidden)

        viewModel.loadData()
        setSelectedTab()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setMapType() {
        mapView.mapType = AppDelegate.shared.currentMapType
        mapTypeButton.text = AppDelegate.shared.currentMapType.description
    }

    private func setSelectedTab() {
        switch (viewModel.tracks.count, viewModel.routes.count, viewModel.waypoints.count) {
        case (0, 0, 0):
            tabBar.selectedItem = tabBar.items?.filter({ $0.tag == TabBarItemTags.tracks }).first

        case (0, 0, _):
            tabBar.selectedItem = tabBar.items?.filter({ $0.tag == TabBarItemTags.waypoints }).first

        case (0, _, _):
            tabBar.selectedItem = tabBar.items?.filter({ $0.tag == TabBarItemTags.routes }).first

        case (_, _, _):
            tabBar.selectedItem = tabBar.items?.filter({ $0.tag == TabBarItemTags.tracks }).first
        }
        setViewModelView()
    }

    private func setViewModelView() {
        switch tabBar.selectedItem!.tag {
        case TabBarItemTags.tracks:
            viewModel.viewChanged(to: .tracks)
        case TabBarItemTags.routes:
            viewModel.viewChanged(to: .routes)
        case TabBarItemTags.waypoints:
            viewModel.viewChanged(to: .waypoints)
        default:
            fatalError("Unexpected selected tab bar tag: \(tabBar.selectedItem!.tag)")
        }
    }

    private struct TabBarItemTags {
        static let tracks = 1
        static let routes = 2
        static let waypoints = 3
    }

    private class MapPickerHelper: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
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
}

extension TrackListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInCurrentView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let props = viewModel.rowProperties(atIndex: indexPath.row)
        cellView.textLabel?.text = props.title
        // Setting `isSelected` doesn't appear to be "enough". The TableView itself needs to "know" that this row is selected.
        if props.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cellView
    }
}

extension TrackListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tabBar.selectedItem!.tag {
        case TabBarItemTags.tracks:
            viewModel.selectTrack(atIndex: indexPath.row)
        case TabBarItemTags.routes:
            viewModel.selectRoute(atIndex: indexPath.row)
        case TabBarItemTags.waypoints:
            viewModel.selectWaypoint(atIndex: indexPath.row)
        default:
            fatalError("Unexpected selected tab bar tag: \(tabBar.selectedItem!.tag)")
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch tabBar.selectedItem!.tag {
        case TabBarItemTags.tracks:
            viewModel.deselectTrack(atIndex: indexPath.row)
        case TabBarItemTags.routes:
            viewModel.deselectRoute(atIndex: indexPath.row)
        case TabBarItemTags.waypoints:
            viewModel.deselectWaypoint(atIndex: indexPath.row)
        default:
            fatalError("Unexpected selected tab bar tag: \(tabBar.selectedItem!.tag)")
        }
    }
}

extension TrackListViewController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setViewModelView()
        tableView.reloadData()
    }
}

extension TrackListViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.lineWidth = 2.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
        annotationView.clusteringIdentifier = "waypoint"
        return annotationView
    }
}

extension TrackListViewController: TrackListViewModelDelegate {

    func reloadView() {
        setSelectedTab()
        tableView.reloadData()
    }

    func showMapArea(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees) {
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setVisibleMapRect(region.mapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
    }

    func showMapArea(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(center, latitudinalMeters, longitudinalMeters)
        mapView.setVisibleMapRect(region.mapRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
    }
}
