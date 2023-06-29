//
//  AssignmentResponse.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import Foundation

// MARK: - AssignmentResponseModel
struct AssignmentResponseModel: Codable {
    let facilities: [Facility]
    let exclusions: [[Exclusion]]
}

extension Array where Element == [Exclusion] {
    func exclusion(withFacility facility: Facility, andOption option: Option) -> [Exclusion]? {
        for var exclusion in self {
            if let index = exclusion.firstIndex(where: {$0.facilityID == facility.facilityID && $0.optionsID == option.id}) {
                exclusion.remove(at: index)
                return exclusion
            }
        }
        return nil
    }
}

// MARK: - Exclusion
struct Exclusion: Codable {
    let facilityID, optionsID: String

    enum CodingKeys: String, CodingKey {
        case facilityID = "facility_id"
        case optionsID = "options_id"
    }
}

// MARK: - Facility
struct Facility: Codable {
    let facilityID, name: String
    let options: [Option]

    enum CodingKeys: String, CodingKey {
        case facilityID = "facility_id"
        case name, options
    }
}

// MARK: - Option
struct Option: Codable {
    let name, icon, id: String
}
