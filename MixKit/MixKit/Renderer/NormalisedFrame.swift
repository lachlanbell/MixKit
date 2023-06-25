//
//  NormalisedFrame.swift
//  MixKit
//
//  Created by Lachlan Bell on 10/9/20.
//  Copyright © 2020 Lachlan Bell. All rights reserved.
//

import Foundation

public struct NormalisedFrame {
    public var minX: Float
    public var maxX: Float
    public var minY: Float
    public var maxY: Float

    public init(minX: Float, minY: Float, maxX: Float, maxY: Float) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
}
