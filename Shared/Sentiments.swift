//
//  FeatureFlags.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import Foundation
import CloudKit

class Sentiments {
    private let container = CKContainer(identifier: "iCloud.app.waggie.Sway-TV")
    private let publicDatabase = CKContainer(identifier: "iCloud.app.waggie.Sway-TV").publicCloudDatabase
    private let recordType = "Sentiment"
    
    func add(currentTrack: String, sentimentName: String) {
        // Create a new CKRecord
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let newRecord = CKRecord(recordType: recordType, recordID: recordID)
        
        // Set the desired fields
        newRecord["currentTrack"] = currentTrack
        newRecord["sentimentName"] = sentimentName
        newRecord["time"] = Date()
        
        // Create a CKModifyRecordsOperation
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [newRecord], recordIDsToDelete: nil)
        modifyOp.savePolicy = .allKeys
        
        modifyOp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error {
                print("CloudKit \(self.recordType) Save Error: \(error)")
            } else if let savedRecords = savedRecords, savedRecords.count > 0 {
                print("Successfully saved \(self.recordType) record to CloudKit")
            }
        }
        
        publicDatabase.add(modifyOp)
    }
}

