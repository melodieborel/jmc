//
//  PlayOrderObject+CoreDataProperties.swift
//  mbTunes
//
//  Created by John Moody on 1/25/18.
//  Copyright © 2018 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//
//

import Foundation
import CoreData


extension PlayOrderObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayOrderObject> {
        return NSFetchRequest<PlayOrderObject>(entityName: "PlayOrderObject")
    }

    @NSManaged public var shuffledPlayOrder: [Int]?
    @NSManaged public var currentPlayOrder: [Int]?
    @NSManaged public var inorderNeedsUpdate: NSNumber?
    @NSManaged public var statusString: String?
    @NSManaged public var sourceListItem: SourceListItem?

}
