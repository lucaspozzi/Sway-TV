//
//  FeatureFlags.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/22/23.
//

import Foundation
import CloudKit
import Combine

//class SentimentsViewModel: ObservableObject {
//    @Published var topTracks: [String] = []
//    
//    private let sentiments = Sentiments()
//    
//    init() {
//        fetchTopTracks()
//    }
//    
//    private func fetchTopTracks() {
//        sentiments.fetchTop10TrackNames { [weak self] tracks, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error fetching top tracks: \(error)")
//                } else if let tracks = tracks {
//                    self?.topTracks = tracks
//                }
//            }
//        }
//    }
//}


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
    
    func fetchTop10TrackNames(completion: @escaping ([(String, Int)]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let records = records else {
                completion(nil, nil)
                return
            }
            
            var trackNamesCount: [String: Int] = [:]
            
            for record in records {
                if let currentTrack = record["currentTrack"] as? String {
                    trackNamesCount[currentTrack] = (trackNamesCount[currentTrack] ?? 0) + 1
                }
            }
            
            // Sort track names by count and limit the result to 10
            let sortedTrackNames = trackNamesCount.sorted(by: { $0.value > $1.value })
            let top10TrackNamesWithCounts = Array(sortedTrackNames.prefix(10))
            
            completion(top10TrackNamesWithCounts, nil)
        }
    }

    
    func fetchTop10TrackNamesWeighted(completion: @escaping ([(String, Int)]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let records = records else {
                completion(nil, nil)
                return
            }
            
            var trackScores: [String: Int] = [:]
            
            for record in records {
                if let currentTrack = record["currentTrack"] as? String, let sentimentName = record["sentimentName"] as? String {
                    var scoreToAdd = 0
                    
                    switch sentimentName {
                    case "like":
                        scoreToAdd = 1
                    case "figure.dance":
                        scoreToAdd = 2
                    case "figure.socialdance":
                        scoreToAdd = 3
                    default:
                        continue
                    }
                    
                    trackScores[currentTrack] = (trackScores[currentTrack] ?? 0) + scoreToAdd
                }
            }
            
            // Sort track names by score and limit the result to 10
            let sortedTracks = trackScores.sorted(by: { $0.value > $1.value })
            let top10TracksWithScores = Array(sortedTracks.prefix(10))
            
            completion(top10TracksWithScores, nil)
        }
    }



}

