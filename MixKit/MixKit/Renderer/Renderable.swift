//
//  Renderable.swift
//  MixKit
//
//  Created by Lachlan Bell on 22/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import Metal

/// Something that can be rendered, i.e. enqueue render commands to a command encoder
protocol Renderable {
    /// Encode commands necessary to render the `Renderable`
    func render(commandEncoder: MTLRenderCommandEncoder)
}
