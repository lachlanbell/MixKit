//
//  TextureViewRenderer.swift
//  MixKit
//
//  Created by Lachlan Bell on 21/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import MetalKit

public class TextureViewRenderer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    public var scene: Scene?

    var pipelineState: MTLRenderPipelineState?

    public init(view: MTKView) {
        // Initialise properties
        self.view = view
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!

        view.clearColor = MTLClearColorMake(0, 0, 0, 1)

        super.init()

        // Setup pipeline
        setupPipelineState()
    }
}

// MARK: - Pipeline Setup
private extension TextureViewRenderer {
    func setupPipelineState() {
        let library = device.makeDefaultLibrary()!

        let vertexFunction = library.makeFunction(name: "vertex_shader")
        let fragmentFunction = library.makeFunction(name: "textured_fragment")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // MARK: - Color attachment descriptor setup
        let colorDescriptor = pipelineDescriptor.colorAttachments[0]
        colorDescriptor?.isBlendingEnabled = true
        colorDescriptor?.pixelFormat = .bgra8Unorm

        // Weighting color combination
        colorDescriptor?.rgbBlendOperation = .add
        colorDescriptor?.alphaBlendOperation = .add

        // Source weighting factors
        colorDescriptor?.sourceRGBBlendFactor = .sourceAlpha
        colorDescriptor?.sourceAlphaBlendFactor = .sourceAlpha

        // Destination weighting factors
        colorDescriptor?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorDescriptor?.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        // MARK: - Vertex descriptor setup

        let vertexDescriptor = MTLVertexDescriptor()
        // Position attributes
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // Color attributes
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

        // Texture attributes
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
        }
    }
}

// MARK: - MTKViewDelegate methods
extension TextureViewRenderer: MTKViewDelegate {

    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        // MARK: - Drawing code
        commandEncoder.setRenderPipelineState(pipelineState)

        scene?.render(commandEncoder: commandEncoder)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
