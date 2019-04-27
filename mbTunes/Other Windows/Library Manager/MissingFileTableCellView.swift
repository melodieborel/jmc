//
//  MissingFileTableCellView.swift
//  mbTunes
//
//  Created by John Moody on 6/16/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

class MissingFileTableCellView: NSTableCellView {
    
    var representedNode: MissingTrackPathNode!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

class MissingFileCellViewWithLocateButton: MissingFileTableCellView {
    
    @IBOutlet var locateButton: NSButton!
    
}
