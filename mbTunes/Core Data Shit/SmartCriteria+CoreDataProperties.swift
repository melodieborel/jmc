//
//  SmartCriteria+CoreDataProperties.swift
//  mbTunes
//
//  Created by John Moody on 5/31/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Foundation
import CoreData


extension SmartCriteria {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SmartCriteria> {
        return NSFetchRequest<SmartCriteria>(entityName: "SmartCriteria")
    }

    @NSManaged public var fetch_limit: NSNumber?
    @NSManaged public var fetch_limit_type: String?
    @NSManaged public var ordering_criterion: String?
    @NSManaged public var predicate: NSObject?
    @NSManaged public var playlist: SongCollection?

}
