//
//  RenderView.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 25/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import MetalKit
import CoreVideo

class RenderView: MTKView {
    var displayLink: CVDisplayLink?

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        self.isPaused = true
        self.enableSetNeedsDisplay = false

        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
