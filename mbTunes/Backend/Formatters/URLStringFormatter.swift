//
//  URLStringFormatter.swift
//  mbTunes
//
//  Created by John Moody on 4/22/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

class URLStringFormatter: Formatter {

    override func string(for obj: Any?) -> String? {
        if let thing = obj as? String {
            return URL(string: thing)!.path
        } else {
            return nil
        }
    }
    
    func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<AnyObject?>>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?) -> Bool {
        return false
    }
}
