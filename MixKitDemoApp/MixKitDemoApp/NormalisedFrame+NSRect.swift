//
//  NormalisedFrame+NSRect.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 10/9/20.
//  Copyright © 2020 Lachlan Bell. All rights reserved.
//

import Foundation
import MixKit

extension NormalisedFrame {
    init(rect: NSRect, parent: NSRect) {
        // Normalise coordinates
        let xmod = parent.width / 2
        let ymod = parent.height / 2

        self.init(
            minX: Float((rect.minX - xmod) / xmod),
            minY: Float((rect.minY - ymod) / ymod),
            maxX: Float((rect.maxX - xmod) / xmod),
            maxY: Float((rect.maxY - ymod) / ymod)
        )
    }

    func denormalised(in parent: NSRect) -> NSRect {
        let xmod = parent.width / 2
        let ymod = parent.height / 2

        let dMinX = (CGFloat(minX) * xmod) + xmod
        let dMaxX = (CGFloat(maxX) * xmod) + xmod
        let dMinY = (CGFloat(minY) * ymod) + ymod
        let dMaxY = (CGFloat(maxY) * ymod) + ymod

        return NSRect(x: dMinX, y: dMinY, width: (dMaxX-dMinX), height: (dMaxY-dMinY))
    }
}
