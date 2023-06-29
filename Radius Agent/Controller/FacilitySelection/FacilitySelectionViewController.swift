//
//  FacilitySelectionViewController.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import UIKit
import Combine

class FacilitySelectionViewController: UIViewController, AlertDisplaying {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = FacilitySelectionViewModel()
    private var observers = Set<AnyCancellable>()
    private let cellIdentifier = "FacilityCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribeToVM()
        viewModel.getFacilities()
    }
    
    private func setupUI() {
        title = "Select Facility"
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: "TitleSubtitleExpandableCardHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TitleSubtitleExpandableCardHeader")
    }
    
    private func subscribeToVM() {
        viewModel.$facilitiesAndExclusions
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                guard let self = self else {return}
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            .store(in: &observers)
        
        viewModel.errorHanding
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.displayAlert(title: "Error", message: error.localizedDescription)
            }
            .store(in: &observers)
    }
}

extension FacilitySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.facilitiesAndExclusions?.facilities.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.facilitiesAndExclusions?.facilities[section].options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.selectionStyle = .none
        if let facility = self.viewModel.facilitiesAndExclusions?.facilities[indexPath.section] {
            let option = facility.options[indexPath.row]
            cell.textLabel?.text = option.name
            cell.imageView?.image = UIImage(named: option.icon)
            cell.accessoryType = self.viewModel.facilitiesSelection[facility.facilityID]?.id == option.id ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let facility = self.viewModel.facilitiesAndExclusions?.facilities[section] else {return nil}
        return facility.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewModel.selectOption(atIndexPath: indexPath) {
            self.tableView.reloadSections([indexPath.section], with: .none)
        }
    }
}

