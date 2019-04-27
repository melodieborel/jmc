//
//  JMDate.swift
//  mbTunes
//
//  Created by John Moody on 6/20/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

public class JMDate: NSObject, NSCoding, NSCopying {
    
    @objc dynamic var date: NSDate
    var hasDay: Bool
    var hasMonth: Bool
    
    init(date: NSDate) {
        self.date = date
        self.hasDay = true
        self.hasMonth = true
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.hasDay = aDecoder.decodeBool(forKey: "hasDay")
        self.hasMonth = aDecoder.decodeBool(forKey: "hasMonth")
        self.date = aDecoder.decodeObject(forKey: "date") as! NSDate
    }
    
    init(year: Int, month: Int? = nil, day: Int? = nil) {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        self.hasDay = day != nil
        self.hasMonth = month != nil
        self.date = dateComponents.date! as NSDate
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.hasDay, forKey: "hasDay")
        aCoder.encode(self.hasMonth, forKey: "hasMonth")
        aCoder.encode(self.date, forKey: "date")
    }

}
