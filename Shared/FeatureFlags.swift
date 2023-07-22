//
//  FeatureFlags.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import Foundation
import CloudKit

class FeatureFlags {
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "FeatureFlags"
    
    
    func fetchFeatureFlag(named featureName: String, completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(format: "featureName = %@", featureName)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .failure(let error):
                print("An error occurred: \(error.localizedDescription)")
                completion(false)
            case .success((let matchResults, _)):
                if let record = matchResults.first?.1,
                   case let .success(recordData) = record,
                   let isEnabled = recordData["isEnabled"] as? Int64 {
                    completion(isEnabled != 0)
                } else {
                    completion(false)
                }
            }
        }
    }
}
