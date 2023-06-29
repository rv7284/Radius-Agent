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
    
    private let viewModel = FacilitySelectionViewModel()
    private var observers = Set<AnyCancellable>()
    private let cellIdentifier = "FacilityCell"
    
    var expandedState = [Bool]()
    
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
                self.expandedState = Array(repeating: false, count: list.facilities.count)
                self.expandedState[0] = true
                self.tableView.reloadData()
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
        if expandedState[section] {
            return self.viewModel.facilitiesAndExclusions?.facilities[section].options.count ?? 0
        }
        return 0
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let facility = self.viewModel.facilitiesAndExclusions?.facilities[section] else {return nil}
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TitleSubtitleExpandableCardHeader") as! TitleSubtitleExpandableCardHeader
        header.lblTitle.text = facility.name
        header.lblSubtitle.text = self.viewModel.facilitiesSelection[facility.facilityID]?.name
        header.arrowIcon.transform = .init(rotationAngle: self.expandedState[section] ? .pi : .zero)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectOption(atIndexPath: indexPath)
        self.tableView.reloadSections([indexPath.section], with: .automatic)
        if indexPath.section < (tableView.numberOfSections - 1) {
            self.expandedState[indexPath.section] = false
            self.expandedState[indexPath.section + 1] = true
            self.tableView.reloadSections([indexPath.section, indexPath.section + 1], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

