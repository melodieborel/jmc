//
//  AlbumFile+CoreDataProperties.swift
//  mbTunes
//
//  Created by John Moody on 6/3/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Foundation
import CoreData


extension AlbumFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlbumFile> {
        return NSFetchRequest<AlbumFile>(entityName: "AlbumFile")
    }

    @NSManaged public var location: String?
    @NSManaged public var file_description: String?
    @NSManaged public var album: Album?

}
