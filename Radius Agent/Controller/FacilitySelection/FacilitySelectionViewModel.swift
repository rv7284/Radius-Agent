//
//  FacilitySelectionViewModel.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import Foundation
import Combine

extension FacilitySelectionViewController {
    class FacilitySelectionViewModel {
        
        @Published var facilitiesAndExclusions: AssignmentResponseModel?
        @Published var errorHanding = PassthroughSubject<Error, Never>()
        
        var facilitiesSelection = [String: Option]()
        
        func getFacilities() {
            Task {
                let result = await NetworkManager.makeRequest(urlRequest: Router.getFacilitiesAndExclusions, model: AssignmentResponseModel.self)
                switch result {
                case .success(let response):
                    facilitiesAndExclusions = response
                case .failure(let error):
                    errorHanding.send(error)
                }
            }
        }
        
        func selectOption(atIndexPath indexPath: IndexPath) {
            guard let facilities = self.facilitiesAndExclusions?.facilities else { return }
            let facility = facilities[indexPath.section]
            facilitiesSelection[facility.facilityID] = facility.options[indexPath.row]
        }
    }
}
