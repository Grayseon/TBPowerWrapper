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
        
        /*NotificationCenter.addObserver(forName: NSNotification.Name(rawValue: NSWorkspace.didWakeNotification.rawValue), object: nil, queue: .main) {notification in
            print("woke up!")
        }*/
        
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { notification in
            print("going to sleep")
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { notification in
            print("waking up")
        }
        
        RunLoop.main.run()
    }
}

let _ = PowerObserver()

/*let desktopPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop").path

print(desktopPath.appending("/hey.txt"))

shell("touch", desktopPath.appending("/hey.txt"))
print(shell("whoami"))*/

