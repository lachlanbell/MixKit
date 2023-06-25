//
//  Scene.swift
//  MixKit
//
//  Created by Lachlan Bell on 22/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import Metal

public class Scene {
    public private(set) var layers: [Layer] = [] {
        didSet {
            observers.forEach { $0.layersDidChange() }
        }
    }

    private var observers: [SceneObserver] = []

    public init() {}

    public func add(layer: Layer) {
        layers.append(layer)
    }

    public func addObserver(_ observer: SceneObserver) {
        observers.append(observer)
    }

    // TODO: Move me into the layer manager, when that gets built
    public func cleanUp() {
        layers.forEach { $0.textureProvider.stop() }
    }
}

extension Scene: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder) {
        // Sequentially render all sublayers
        layers.forEach { $0.render(commandEncoder: commandEncoder) }
    }
}
