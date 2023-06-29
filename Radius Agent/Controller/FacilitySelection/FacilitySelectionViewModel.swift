//
//  FacilitySelectionViewModel.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import Foundation
import Combine

extension FacilitySelectionViewController {
    enum AppError: Error, LocalizedError {
        case exclusion(option: Option, currentSelection: String)
        
        var errorDescription: String? {
            switch self {
            case .exclusion(let option, let currentSelection):
                return "You can not select \(option.name) with \(currentSelection)."
            }
        }
    }
    
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
        
        func selectOption(atIndexPath indexPath: IndexPath) -> Bool {
            guard let facilities = self.facilitiesAndExclusions?.facilities, let appExclusions = self.facilitiesAndExclusions?.exclusions else { return false }
            let facility = facilities[indexPath.section]
            let option = facility.options[indexPath.row]
            if let exclusions = appExclusions.exclusion(withFacility: facility, andOption: option) {
                //This will handle cases where more than 2 conditions are needed in exclusion
                var matchedCases = 0
                var currentSelection = ""
                for exclusion in exclusions {
                    if let option = facilitiesSelection[exclusion.facilityID], option.id == exclusion.optionsID {
                        if currentSelection.isEmpty {
                            currentSelection = option.name
                        } else {
                            currentSelection += (", " + option.name)
                        }
                        matchedCases += 1
                    }
                }

                if matchedCases == exclusions.count {
                    errorHanding.send(AppError.exclusion(option: option, currentSelection: currentSelection))
                    return false
                }
            }
            facilitiesSelection[facility.facilityID] = option
            return true
        }
    }
}
