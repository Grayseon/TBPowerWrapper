//
//  main.swift
//  TBPowerWrapper
//
//  Created by Grayson Dorsher on 10/26/24.
//

import Foundation
import Cocoa
import os

enum ShellError: Error {
    case processLaunchFailed
    case processFailed
}

let logger = Logger()

func shell(_ args: String..., completion: ((Int32)->(Void))?) throws {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    do {
        try task.run()
    } catch {
        throw ShellError.processLaunchFailed
    }
    task.waitUntilExit()
    let status = task.terminationStatus
    
    if status != 0 {
        throw ShellError.processFailed
    }
    
    completion?(status)
}

func unloadKext(completion: @escaping ()->()) throws {
    do {
        try shell("sudo", "kextunload", "/Library/Extensions/TB.kext") {_ in
            completion()
        }
    } catch {
        logger.trace("Didn't unload")
        throw ShellError.processFailed
    }
}

func loadKext(completion: @escaping ()->()) throws {
    do {
        try shell("sudo", "kextutil", "/Library/Extensions/TB.kext") { status in
            completion()
        }
    } catch {
        logger.trace("Didn't load")
        throw ShellError.processFailed
    }
}

class PowerObserver {
    init() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        print("Listening for power events")
        do {
            try unloadKext() {
                print("Unloaded")
                do {
                    try loadKext() {
                        print("Successfully reloaded kext")
                    }
                } catch {
                    logger.trace("Unsuccessful in loading")
                }
            }
        } catch {
            logger.trace("Unsuccesful in unloading")
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { notification in
            print("Going to sleep")
            try? unloadKext() {
                print("Unloaded")
            }
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { notification in
            print("Woke up")
            try? loadKext() {
                print("Loaded")
            }
        }
        
        RunLoop.main.run()
    }
}

if(CommandLine.arguments.count > 1) {
    switch(CommandLine.arguments[1]) {
    case "load":
        do {
            try loadKext() {
                print("Attempting to load kext")
            }
            
            print("Successfully loaded kext")
            print("Warning: This will only start the kext once. Once the power state changes the effects will be disable.")
        } catch {
            logger.trace("Unable to load kext")
        }
    case "unload":
        do {
            try unloadKext() {
                print("Attemping to unload kext")
            }
            
            print("Successfully unloaded kext")
        } catch {
            logger.trace("Unable to load kext")
        }
    default:
        print("No arguments")
    }
} else {
    let _ = PowerObserver()
}
