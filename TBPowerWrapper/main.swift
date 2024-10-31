//
//  main.swift
//  TBPowerWrapper
//
//  Created by Grayson Dorsher on 10/26/24.
//

import Foundation
import Cocoa

enum ShellError: Error {
    case processLaunchFailed
    case processFailed
}

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
        try shell("sudo", "kextunload", "/applications/tbswitcher_resources/disableturboboost.64bits.kext") {_ in
            completion()
        }
    } catch {
        print("didn't unload")
    }
}

func loadKext(completion: @escaping ()->()) throws {
    do {
        try shell("sudo", "kextutil", "/applications/tbswitcher_resources/disableturboboost.64bits.kext") { status in
            completion()
        }
    } catch {
        throw ShellError.processFailed
    }
}

class PowerObserver {
    init() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        print("listening for power events")
        do {
            try unloadKext() {
                print("unloaded")
                do {
                    try loadKext() {
                        print("successfully reloaded kext")
                    }
                } catch {
                    print("unsuccessful in loading")
                }
            }
        } catch {
            print("unsuccesful in unloading")
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { notification in
            print("going to sleep")
            try? unloadKext() {
                print("unloaded")
            }
        }
        
        notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { notification in
            print("woke up")
            try? loadKext() {
                print("loaded")
            }
        }
        
        RunLoop.main.run()
    }
}

switch(CommandLine.arguments[1]) {
case "load":
    let _ = PowerObserver()
case "unload":
    do {
        try unloadKext() {
            print("Attemping to unload kext")
        }
        
        print("Successfully unloaded kext")
    } catch {
        print("Unable to load kext")
    }
default:
    print("No arguments")
}
