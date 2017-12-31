//
//  FileListViewController.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit

final class FileListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private lazy var viewModel = FileLisViewModel(moc: AppDelegate.shared.coreDataContainer.viewContext, delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllerBindings.title.bind(viewModel.title)
        view.viewBindings.loadingViewIsHidden.bind(viewModel.loadingViewIsHidden)

        tableView.dataSource = self
        tableView.delegate = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadData()
    }

    @objc private func refreshTable(sender: UIRefreshControl) {
        viewModel.loadData()
        sender.endRefreshing()
    }
}

extension FileListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fileEntity = viewModel.files[indexPath.row]
        cellView.textLabel?.text = fileEntity.name
        if let tracks = fileEntity.tracks, let routes = fileEntity.routes, let waypoints = fileEntity.waypoints {
            cellView.detailTextLabel?.text = "\(tracks.count) track(s), \(routes.count) route(s), \(waypoints.count) waypoint(s)"
        }
        else {
            cellView.detailTextLabel?.text = ""
        }
        return cellView
    }

}

extension FileListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileEntity = viewModel.files[indexPath.row]
        let vc = TrackListViewController.create(withFile: fileEntity)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if viewModel.deleteFile(atIndex: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension FileListViewController: FileLisViewModelDelegate {

    func reloadView() {
        tableView.reloadData()
    }
}
