//
//  ProgressBarController.swift
//  mbTunes
//
//  Created by John Moody on 4/13/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

protocol ProgressBarController {
    
    var actionName: String { get set }
    var thingName: String { get set }
    var thingCount: Int { get set }
    
    func prepareForNewTask(actionName: String, thingName: String, thingCount: Int)
    func increment(thingsDone: Int)
    func makeIndeterminate(actionName: String)
    func finish()
    
}
