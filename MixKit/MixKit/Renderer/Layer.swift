//
//  Layer.swift
//  MixKit
//
//  Created by Lachlan Bell on 22/11/19.
//  Copyright © 2019 Lachlan Bell.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Metal

/// A single layer, that draws a texture from a `TextureProvider` on  a `Plane`
public class Layer {
    public var name: String

    public var frame = NormalisedFrame(minX: -1, minY: -1, maxX: 1, maxY: 1) {
        didSet {
            backingPlane.setFrame(frame: frame)
        }
    }

    var textureProvider: TextureProvider
    let device: MTLDevice

    let backingPlane: Plane

    public init(name: String, textureProvider: TextureProvider, device: MTLDevice) {
        self.name = name
        self.textureProvider = textureProvider
        self.device = device

        backingPlane = Plane(device: device)
    }
}

extension Layer: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder) {
        // Get the next frame from the texture provider
        guard let texture = textureProvider.nextFrame() else { return }

        // Texture backing plane and render
        backingPlane.render(commandEncoder: commandEncoder, texture: texture)
    }
}
