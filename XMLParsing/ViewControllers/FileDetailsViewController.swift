//
//  FileDetailsViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import UIKit
import MapKit

final class FileDetailsViewController: UIViewController {
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapTypeButton: PickerButton!
    @IBOutlet private var tabBar: UITabBar!

    private weak var pageViewController: PageViewController!

    private var viewModel: FileDetailsViewModel!
    private let mapPickerHelper = MapPickerHelper()

    static func create(withFile file: GpxFileEntity) -> FileDetailsViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FileDetailsViewController") as! FileDetailsViewController
        vc.viewModel = FileDetailsViewModel(file: file, moc: AppDelegate.shared.coreDataContainer.viewContext, delegate: vc)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapPickerHelper.rowSelected = { [weak self] mapType in
            guard let strongSelf = self else { return }
            strongSelf.dismissKeyboard()
            AppDelegate.shared.currentMapType = mapType
            strongSelf.setMapType()
        }
        mapTypeButton.inputView = {
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

        mapView.delegate = self

        tabBar.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            for tab in tabBar.items! {
                tab.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
            }
        }

        viewControllerBindings.title.bind(viewModel.title)
        view.viewBindings.loadingViewIsHidden.bind(viewModel.loadingViewIsHidden)

        viewModel.loadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSegue" {
            pageViewController = segue.destination as! PageViewController
            pageViewController.pageViewControllerDelegate = self
            pageViewController.mapView = mapView
            pageViewController.createDataSource(withMapDisplayDelegate: self, gpxFileProvider: viewModel)
            pageViewController.showViewController(for: .all)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setMapType() {
        mapView.mapType = AppDelegate.shared.currentMapType
        mapTypeButton.text = AppDelegate.shared.currentMapType.description
    }
}

extension FileDetailsViewController: FileDetailsViewModelDelegate {

    func dataLoaded(defaultListResult: Result<FileDetailsViewModel.ListType>) {
        switch defaultListResult {
        case .success(let defaultList):
            pageViewController.fileLoaded(viewModel.fileEntity)
            pageViewController.showViewController(for: defaultList.pageTab)
        case .failure:
            // TODO: Show an error message to the user
            break
        }
    }
}

extension FileDetailsViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? GpxPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = polyline.type == .trackSegment ? .red : .purple
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

extension FileDetailsViewController: UITabBarDelegate {

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        pageViewController.showViewController(atIndex: item.tag - 1)
    }
}

extension FileDetailsViewController: PageViewControllerDelegate {

    func pageViewController(_ pageViewController: PageViewController, pageChangedTo pageTab: PageTab) {
        guard let tabItem = tabBar.items?.filter({ $0.tag == pageTab.rawValue }).first else {
            fatalError("No matching tab bar item for PageTab: \(pageTab)")
        }
        tabBar.selectedItem = tabItem
    }
}

extension FileDetailsViewController: MapDisplayDelegate {

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

extension FileDetailsViewModel.ListType {

    var pageTab: PageTab {
        switch self {
        case .all:
            return .all
        case .tracks:
            return .tracks
        case .routes:
            return .routes
        case .waypoints:
            return .waypoints
        }
    }
}
