//
//  SourceListItem+CoreDataClass.swift
//  mbTunes
//
//  Created by John Moody on 6/10/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Foundation
import CoreData


public class SourceListItem: NSManagedObject {

    func dictRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["is_header"] = self.is_header
        dict["name"] = self.name
        dict["sort_order"] = self.sort_order
        dict["id"] = self.playlist?.id
        return dict
    }
    
    var tableViewController: LibraryTableViewController?
    
}
