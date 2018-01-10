//
//  PageViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit
import UIKit

public enum PageTab: Int {
    case all = 1, tracks, routes, waypoints
}

protocol PageViewControllerDelegate: class {
    func pageViewController(_ pageViewController: PageViewController, pageChangedTo pageTab: PageTab)
}

final class PageViewController: UIPageViewController {
    public weak var pageViewControllerDelegate: PageViewControllerDelegate?
    public weak var mapView: MKMapView?

    private var orderedViewControllers: [ListViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
    }

    func createDataSource(withMapDisplayDelegate delegate: MapDisplayDelegate, gpxFileProvider: GpxFileProviding) {
        orderedViewControllers = [
            AllListViewController.create(),
            TracksListViewController.create(),
            RoutesListViewController.create(withMapDisplayDelegate: delegate, gpxFileProvider: gpxFileProvider, mapView: mapView),
            WaypointsListViewController.create(withMapDisplayDelegate: delegate, mapView: mapView)
        ]
    }

    func fileLoaded(_ gpxFile: GpxFileEntity) {
        orderedViewControllers.forEach { $0.fileLoaded(gpxFile) }
    }

    func showViewController(for pageTab: PageTab) {
        showViewController(atIndex: pageTab.rawValue - 1)
    }

    func showViewController(atIndex index: Int) {
        guard index >= 0, index < orderedViewControllers.count else {
            Logger.warning(category: .view, "Index out of range: \(index)")
            return
        }

        let vc = orderedViewControllers[index]

        guard let currentVC = viewControllers?.first as? ListViewController, let currentIndex = orderedViewControllers.index(of: currentVC) else {
            setViewController(vc, direction: .forward)
            pageChanged(toIndex: index)
            return
        }
        guard currentIndex != index else {
            return
        }

        if index < currentIndex {
            setViewController(vc, direction: .reverse)
            pageChanged(toIndex: index)
        } else {
            setViewController(vc, direction: .forward)
            pageChanged(toIndex: index)
        }
    }

    // In order to work around a bug in the UIPageViewController when using the scroll animaton and calling setViewControllers(... animated: true ...)
    // See: https://stackoverflow.com/questions/12939280/uipageviewcontroller-navigates-to-wrong-page-with-scroll-transition-style
    private func setViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection) {
        setViewControllers([viewController], direction: direction, animated: true) { [weak self] done in
            if done {
                // On the next run loop
                DispatchQueue.main.async { [weak self] in
                    self?.setViewControllers([viewController], direction: direction, animated: false, completion: nil)
                }
            }
        }
    }

    private func pageChanged(toIndex newIndex: Int) {
        guard let pageTab = PageTab(rawValue: newIndex + 1) else {
            fatalError("No PageTab enum for index: \(index)")
        }

        // unbind the MapView...
        mapView?.mapViewBindings.waypoints.unbind()
        mapView?.mapViewBindings.gpxRoutes.unbind()

        // ... and clear all the annotations and overlays
        if let mapView = mapView {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }

        // bind the MapView to the current ViewController
        orderedViewControllers[newIndex].bindViewModel()

        pageViewControllerDelegate?.pageViewController(self, pageChangedTo: pageTab)
    }
}

extension PageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = orderedViewControllers.index(of: viewController as! ListViewController) else {
            return nil
        }

        let previousIndex = currentIndex - 1

        guard previousIndex >= 0, orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = orderedViewControllers.index(of: viewController as! ListViewController) else {
            return nil
        }

        let nextIndex = currentIndex + 1

        guard orderedViewControllers.count > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }
}

extension PageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentVC = viewControllers?.first as? ListViewController, let currentIndex = orderedViewControllers.index(of: currentVC) else {
            return
        }

        pageChanged(toIndex: currentIndex)
    }
}
