//
//  ImageTextureProvider.swift
//  MixKit
//
//  Created by Lachlan Bell on 22/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
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
