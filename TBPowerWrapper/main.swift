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
        
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { notification in
            print("going to sleep")
            shell("sudo", "kextunload", "/applications/turboswitcher_resources/disableturboboost.64bits.kext")
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { notification in
            print("woke up")
            shell("sudo", "kextutil", "/applications/turboswitcher_resources/disableturboboost.64bits.kext")
        }
        
        RunLoop.main.run()
    }
}

let _ = PowerObserver()
