//
//  ImageTextureProvider.swift
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
import MetalKit

public class ImageTextureProvider: TextureProvider {
    
    var imageTexture: MTLTexture?
    var imageURL: URL?

    let textureLoader: MTKTextureLoader

    public init(device: MTLDevice, image: CGImage) {
        textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions = [
            MTKTextureLoader.Option.origin: NSString(string: MTKTextureLoader.Origin.bottomLeft.rawValue),
            MTKTextureLoader.Option.SRGB: image.colorSpace == CGColorSpace(name: CGColorSpace.sRGB)
        ] as [MTKTextureLoader.Option : Any]

        imageTexture = try? textureLoader.newTexture(cgImage: image, options: textureLoaderOptions)
    }

    public convenience init?(device: MTLDevice, imageUrl: URL) {
        guard let image = NSImage(contentsOf: imageUrl) else { return nil }
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        self.init(device: device, image: cgImage)
    }
    
    private func setTexture() {}

    public func nextFrame() -> MTLTexture? {
        return imageTexture
    }

    public func start() { /* No-op */ }
    public func stop() { /* No-op */ }

}
