//
//  Scene.swift
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
