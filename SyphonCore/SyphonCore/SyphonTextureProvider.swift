//
//  SyphonLayerProvider.swift
//  MixKitTests
//
//  Created by Lachlan Bell on 19/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import MixKit
import IOKit
import Metal
import OpenGL
import Syphon

public class SyphonTextureProvider {
    var syphonClient: SyphonMetalClient!
    var texture: MTLTexture? = nil

    public var name: String?

    public init?(gpu: MTLDevice, index: Int) {
        let serverObj = SyphonServerDirectory.shared().servers[index]

        guard let server = serverObj as? [AnyHashable: Any] else { return nil }

        if let appName = server[SyphonServerDescriptionAppNameKey] as? String {
            if let serverName = server[SyphonServerDescriptionNameKey] as? String {
                self.name = "\(appName) (\(serverName))"
            } else {
                self.name = "\(appName)"
            }
        }

        syphonClient = SyphonMetalClient(
            serverDescription: server,
            device: gpu,
            options: nil,
            newFrameHandler: { (client) in
                self.setTexture(texture: client?.newFrameImage())
            }
        )
    }

    public func stop() { syphonClient.stop() }
}

extension SyphonTextureProvider: TextureProvider {
    func setTexture(texture: MTLTexture?) {
        self.texture = texture
    }

    public func nextFrame() -> MTLTexture? {
        return texture
    }

    public func start() { /* No-op */ }
}
