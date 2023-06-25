//
//  Plane.swift
//  MixKit
//
//  Created by Lachlan Bell on 22/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import Metal

/// A 2D plane that can be textured and rendered
class Plane {
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?

    var device: MTLDevice

    //  ╔══════════════════════════════════════╗
    //  ║      Drawing Coordinate System       ║
    //  ╚══════════════════════════════════════╝
    //   top-left                    top-right
    //   V: -1,1    0──────────────3 V: 1,1
    //   T: 0,1     │╲             │ T: 1,1
    //              │ ╲            │
    //              │  ╲  Triangle │
    //              │   ╲    1     │
    //              │    ╲         │
    //              │     ╲        │
    //              │      ╲       │
    //              │       ╲      │
    //              │        ╲     │
    //              │         ╲    │
    //              │          ╲   │
    //              │ Triangle  ╲  │
    //              │    0       ╲ │
    //  bottom-left │             ╲│ bottom-right
    //  V: -1,-1    1──────────────2 V: 1,-1
    //  T: 0,0                       T: 1,0
    //  ────────────────────────────────────────
    //  v = vertex position coordinates
    //  t = texture position
    var vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1, 1, 0),    // Vertex 0 (top-left)
            color: SIMD4<Float>(1, 0, 0, 1),
            texture: SIMD2<Float>(0, 1)),
        Vertex(position: SIMD3<Float>(-1, -1, 0),   // Vertex 1 (bottom-left)
            color: SIMD4<Float>(0, 1, 0, 1),
            texture: SIMD2<Float>(0, 0)),
        Vertex(position: SIMD3<Float>(1, -1, 0),    // Vertex 2 (bottom-right)
            color: SIMD4<Float>(0, 0, 1, 1),
            texture: SIMD2<Float>(1, 0)),
        Vertex(position: SIMD3<Float>(1, 1, 0),     // Vertex 3 (top-right)
            color: SIMD4<Float>(1, 0, 1, 1),
            texture: SIMD2<Float>(1, 1))
    ]

    // Form a quad out of 2 triangles
    // Using the the indices of the above position vertices
    let indices: [UInt16] = [
        0, 1, 2,    // Triangle 0: top-left -> bottom-left -> bottom-right
        2, 3, 0     // Triangle 1: bottom-right -> top-right -> top-left
    ]

    /// - Parameter device: Active GPU
    init(device: MTLDevice) {
        self.device = device
        setupBuffers(device: device)
    }

    /// Create the vertex and index buffers for the plane on the GPU
    /// - Parameter device: Active GPU
    func setupBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )

        indexBuffer = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }

    /// Add the commands necessary to render a texture onto the plane to a render command encoder
    /// - Parameter commandEncoder: Render command encoder to add to
    /// - Parameter texture: Texture to draw onto the plane
    func render(commandEncoder: MTLRenderCommandEncoder, texture: MTLTexture) {
        guard let indexBuffer = indexBuffer else { return }

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        commandEncoder.setFragmentTexture(texture, index: 0)

        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }

    public func setFrame(frame: NormalisedFrame) {
        vertices = [
            Vertex(position: SIMD3<Float>(frame.minX, frame.maxY, 0),    // Vertex 0 (top-left)
                color: SIMD4<Float>(1, 0, 0, 1),
                texture: SIMD2<Float>(0, 1)),
            Vertex(position: SIMD3<Float>(frame.minX, frame.minY, 0),    // Vertex 1 (bottom-left)
                color: SIMD4<Float>(0, 1, 0, 1),
                texture: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD3<Float>(frame.maxX, frame.minY, 0),    // Vertex 2 (bottom-right)
                color: SIMD4<Float>(0, 0, 1, 1),
                texture: SIMD2<Float>(1, 0)),
            Vertex(position: SIMD3<Float>(frame.maxX, frame.maxY, 0),    // Vertex 3 (top-right)
                color: SIMD4<Float>(1, 0, 1, 1),
                texture: SIMD2<Float>(1, 1))
        ]

        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
    }
}
