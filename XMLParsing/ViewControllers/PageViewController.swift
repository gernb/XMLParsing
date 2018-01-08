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

class PageViewController: UIPageViewController {
    public weak var pageViewControllerDelegate: PageViewControllerDelegate?
    public weak var mapView: MKMapView?

    private var orderedViewControllers: [ListViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
    }

    func createDataSource(withMapDisplayDelegate delegate: MapDisplayDelegate) {
        orderedViewControllers = [
            AllListViewController.create(),
            TracksListViewController.create(),
            RoutesListViewController.create(),
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
            setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            pageChanged(toIndex: index)
            return
        }
        guard currentIndex != index else {
            return
        }

        if index < currentIndex {
            setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            pageChanged(toIndex: index)
        } else {
            setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            pageChanged(toIndex: index)
        }
    }

    private func pageChanged(toIndex newIndex: Int) {
        guard let pageTab = PageTab(rawValue: newIndex + 1) else {
            fatalError("No PageTab enum for index: \(index)")
        }

        // unbind the MapView
        mapView?.mapViewBindings.waypoints.unbind()

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

        Logger.verbose(category: .view, "New page index: \(currentIndex)")

        pageChanged(toIndex: currentIndex)
    }
}
