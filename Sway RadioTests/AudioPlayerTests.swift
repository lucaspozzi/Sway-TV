//
//  AudioPlayerTests.swift
//  Sway RadioTests
//
//  Created by Lucas Pozzi de Souza on 8/29/23.
//

import XCTest
@testable import Sway_Radio
import AVFAudio
//@testable import Sway_TV

final class AudioPlayerTests: XCTestCase {
    
    private var audioPlayer: AudioPlayer!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    override func setUp() {
        super.setUp()
        audioPlayer = AudioPlayer()
    }
    
    override func tearDown() {
        audioPlayer = nil
        super.tearDown()
    }
    
//    func testSetupAudioPlayer() {
//        XCTAssertEqual(audioPlayer.audioPlayer.automaticallyWaitsToMinimizeStalling, true)
//        XCTAssertEqual(audioPlayer.audioPlayer.allowsExternalPlayback, true)
//    }
    
    func testStartPlayback() {
        audioPlayer.startPlayback()
        
        let expectation = XCTestExpectation(description: "Audio player is playing")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            XCTAssertTrue(self.audioPlayer.isPlaying)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
//    func testSetupAudioSession() {
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
//            try audioSession.setActive(true)
//        } catch {
//            XCTFail("Failed to set up audio session")
//        }
//    }
    
//    func testHandleInterruption() {
//        let expectedInterruptionTypes = [.began, .ended]
//        for interruptionType in expectedInterruptionTypes {
//            audioPlayer.handleInterruption(Notification(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: UInt(interruptionType)]))
//            XCTAssertEqual(audioPlayer.audioPlayer.isPlaying, interruptionType == .ended)
//        }
//    }
//    
//    func testHandleRouteChange() {
//        let expectedRouteChangeReasons = [.newDeviceAvailable, .oldDeviceUnavailable]
//        for routeChangeReason in expectedRouteChangeReasons {
//            audioPlayer.handleRouteChange(Notification(name: AVAudioSession.routeChangeNotification, object: nil, userInfo: [AVAudioSessionRouteChangeReasonKey: UInt(routeChangeReason)]))
//            XCTAssertEqual(audioPlayer.audioPlayer.isPlaying, routeChangeReason == .newDeviceAvailable)
//        }
//    }

}
