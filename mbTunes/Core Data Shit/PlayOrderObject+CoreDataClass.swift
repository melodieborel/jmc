//
//  PlayOrderObject+CoreDataClass.swift
//  mbTunes
//
//  Created by John Moody on 1/25/18.
//  Copyright © 2018 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Foundation
import CoreData


public class PlayOrderObject: NSManagedObject {

    func libraryStatusNeedsUpdate() {
        let viewController = self.sourceListItem?.tableViewController
        let volumes = Set((viewController?.trackViewArrayController.arrangedObjects as! [TrackView]).compactMap({return $0.track!.volume}))
        var count = 0
        var missingVolumes = [Volume]()
        for volume in volumes {
            if !volumeIsAvailable(volume: volume) {
                count += 1
                missingVolumes.append(volume)
            }
        }
        for volume in missingVolumes {
            let IDs = Set((volume.tracks as! Set<Track>).map({return Int(truncating: $0.id!)}))
            self.currentPlayOrder = self.currentPlayOrder!.filter({return !IDs.contains($0)})
        }
        if count > 0 {
            DispatchQueue.main.async {
                viewController?.mainWindowController?.sourceListViewController?.reloadData()
            }
        }
    }
}
