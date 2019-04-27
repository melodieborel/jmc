//
//  TimeFormatter.swift
//  mbTunes
//
//  Created by John Moody on 3/25/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

class TimeFormatter: NumberFormatter {
    
    override func string(for obj: Any?) -> String? {
        //could probably be written better
        guard let type = obj as? NSNumber else {
            return nil
        }
        let hr = type.intValue / 3600000
        let min = (type.intValue - (hr * 3600000)) / 60000
        let sec = (type.intValue - (hr * 3600000) - (min * 60000)) / 1000
        var stamp = ""
        if (sec < 10) {
            stamp = "\(min):0\(sec)"
        }
        else {
            stamp = "\(min):\(sec)"
        }
        if hr != 0 {
            if (min < 10) {
                stamp = "\(hr):0\(stamp)"
            }
            else {
                stamp = "\(hr):\(stamp)"
            }
        }
        return stamp
    }
    
    func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<AnyObject?>>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<AutoreleasingUnsafeMutablePointer<NSString?>>?) -> Bool {
        return false
    }
}
