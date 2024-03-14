//
//  BackgroundTaskManager.swift
//  FuncTest-swift
//
//  Created by admin on 2022/11/26.
//  Copyright © 2022 Wrxdz. All rights reserved.
//

import Foundation
import AVFAudio

class BackgroundTaskManager {
    
    static var shared: BackgroundTaskManager {
        get {
            return getInstance()
        }
    }
    
    private static var manager: BackgroundTaskManager?
    
    private class func getInstance() -> BackgroundTaskManager {
        if manager == nil {
            manager = BackgroundTaskManager()
        }
        return manager!
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    private var timer: Timer?
    
    fileprivate init() {
        do {
           
            let player = try AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: videoPath()))
            player.numberOfLoops = -1
            player.volume = 0
            self.audioPlayer = player
            
            //设置后台模式和锁屏模式下依然能够播放
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            self.audioPlayer = nil
            Log.d("AAAA", msg: "BackgroundTaskManager init error")
        }
        
    }
    
    private func videoPath() -> String {
        return Bundle.main.path(forResource: "holder", ofType: "mp4")!
    }
    
    func startPlayAudioSession() {
        audioPlayer?.play()
    }
    
    func stopPlayAudioSession() {
        audioPlayer?.stop()
    }
    
    
}
