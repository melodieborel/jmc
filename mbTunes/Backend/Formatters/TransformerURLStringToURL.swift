//
//  TransformerURLStringToURL.swift
//  mbTunes
//
//  Created by John Moody on 4/22/17.
//  Copyright © 2017 John Moody. All rights reserved.
//  Modified by Melodie Borel on 4/27/19.
//

import Cocoa

class TransformerURLStringToURL: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSURL.self
    }
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? String else {
            return nil
        }
        return URL(string: type)
    }

}
