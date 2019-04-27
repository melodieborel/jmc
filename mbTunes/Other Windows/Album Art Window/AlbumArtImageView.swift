//
//  AlbumArtImageView.swift
//  mbTunes
//
//  Created by John Moody on 5/21/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

class AlbumArtImageView: NSImageView {
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
