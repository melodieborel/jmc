//
//  Volume+CoreDataProperties.swift
//  mbTunes
//
//  Created by John Moody on 6/21/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Foundation
import CoreData


extension Volume {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Volume> {
        return NSFetchRequest<Volume>(entityName: "Volume")
    }

    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var library: Library?
    @NSManaged public var source_list_item: SourceListItem?
    @NSManaged public var tracks: NSSet?

}

// MARK: Generated accessors for tracks
extension Volume {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}
