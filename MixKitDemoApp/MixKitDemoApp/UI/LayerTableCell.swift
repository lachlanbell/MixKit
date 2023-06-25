//
//  LayerTableCell.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 24/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import MetalKit
import MixKit

class LayerTableCell: NSTableCellView {
    @IBOutlet weak var layerPreviewView: NSView!
    @IBOutlet weak var nameLabel: NSTextField!

    var renderer: TextureViewRenderer!

    func configure(with layer: Layer) {
        nameLabel.stringValue = layer.name

        // Setup preview
        let device = MTLCreateSystemDefaultDevice()!
        let metalView = MTKView(frame: layerPreviewView.bounds, device: device)
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = false

        self.layerPreviewView.addSubview(metalView)
        renderer = TextureViewRenderer(view: metalView)
        metalView.delegate = renderer

        RenderManager.shared.addDependentView(metalView)

        let previewScene = Scene()
        previewScene.add(layer: layer)
        renderer.scene = previewScene
    }
}
