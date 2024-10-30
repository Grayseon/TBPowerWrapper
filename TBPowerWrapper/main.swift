//
//  main.swift
//  TBPowerWrapper
//
//  Created by Grayson Dorsher on 10/26/24.
//

import Foundation
import Cocoa

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

class PowerObserver {
    init(){
        let notificationCenter = NSWorkspace.shared.notificationCenter
        print("listening for power events")
        self.load()
        
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { notification in
            print("going to sleep")
            self.unload()
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { notification in
            print("woke up")
            self.load()
        }
        
        RunLoop.main.run()
    }
    
    private func unload(){
        print("unloading")
        shell("sudo", "kextunload", "/applications/tbswitcher_resources/disableturboboost.64bits.kext")
    }
    
    private func load(){
        print("loading")
        shell("sudo", "kextutil", "/applications/tbswitcher_resources/disableturboboost.64bits.kext")
    }
}

let _ = PowerObserver()
