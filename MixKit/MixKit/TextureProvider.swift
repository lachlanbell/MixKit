//
//  TextureProvider.swift
//  MixKit
//
//  Created by Lachlan Bell on 20/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import Metal

@objc public protocol TextureProvider {
    /// Get the next frame as a texture
    func nextFrame() -> MTLTexture?

    /// Start providing textures (optional)
    func start()

    /// Stop providing textures (optional)
    func stop()
}
