//
//  ViewController.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 21/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import AppKit
import MixKit
import Metal
import MetalKit
import SyphonCore
import Syphon

class ViewController: NSViewController {

    @IBOutlet weak var previewView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var selectionView: AirSightResizeView!

    let device = MTLCreateSystemDefaultDevice()!

    let directory = SyphonServerDirectory.shared()
    var metalView: MTKView!
    var renderer: TextureViewRenderer!

    var previewScene: Scene!

    var clicked = false

    let sourceMenu = NSMenu(title: "Source")

    weak var selectedLayer: Layer?

    override func viewDidLoad() {
        buildSourceMenu()

        metalView = MTKView(frame: previewView.bounds, device: device)
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = false
        renderer = TextureViewRenderer(view: metalView)

        previewScene = Scene()
        renderer.scene = previewScene

        metalView.delegate = renderer
        previewView.addSubview(metalView)

        RenderManager.shared.addDependentView(metalView)

        tableView.dataSource = self
        tableView.delegate = self

        // Set up selectionview
        selectionView.respectsProportion = true
        selectionView.delegate = self
        selectionView.selectedFrame = metalView.frame
        selectionView.isHidden = true
    }

    override func viewWillDisappear() {
        previewScene.cleanUp()
    }

    override func mouseDown(with event: NSEvent) {
        if let mouseLocation = self.view.window?.mouseLocationOutsideOfEventStream {
            let point = self.metalView.convert(mouseLocation, from: self.view)

            for layer in previewScene.layers.reversed() {
                if layer.frame.denormalised(in: metalView.frame).contains(point) {
                    selectedLayer = layer
                    selectionView.selectedFrame = layer.frame.denormalised(in: metalView.frame)
                    break;
                }
            }
        }
    }

    func buildSourceMenu() {
        sourceMenu.insertItem(withTitle: "Live Source", action: nil, keyEquivalent: "", at: 0)
        sourceMenu.insertItem(withTitle: "File", action: #selector(addImageLayer), keyEquivalent: "", at: 1)
    }

    func updateLiveSourceSubmenu() {
        let menu = NSMenu()

        SyphonServerDirectory.shared().servers.forEach { server in
            guard let server = server as? [AnyHashable: Any] else { return }

            if let appName = server[SyphonServerDescriptionAppNameKey] as? String {
                let sourceName: String

                if let serverName = server[SyphonServerDescriptionNameKey] as? String {
                    sourceName = "\(appName) (\(serverName))"
                } else {
                    sourceName = "\(appName)"
                }

                let menuItem = NSMenuItem(
                    title: sourceName,
                    action: #selector(addSyphonLayer(sender:)),
                    keyEquivalent: ""
                )
                menuItem.tag = menu.items.endIndex
                menu.addItem(menuItem)
            }
        }

        sourceMenu.setSubmenu(menu, for: sourceMenu.item(at: 0)!)
    }

    @objc func addSyphonLayer(sender: NSMenuItem) {
        let textureProvider = SyphonTextureProvider(gpu: device, index: sender.tag)!

        let syphonLayer = Layer(
            name: textureProvider.name ?? "Syphon",
            textureProvider:textureProvider,
            device: device
        )

        previewScene.add(layer: syphonLayer)
        updateTable()

        selectedLayer = syphonLayer
        selectionView.selectedFrame = syphonLayer.frame.denormalised(in: metalView.frame)
        selectionView.isHidden = false
    }

    @objc func addImageLayer() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        guard openPanel.runModal() == .OK else { return }
        guard let fileUrl = openPanel.urls.first else { return }

        let textureProvider = ImageTextureProvider(device: device, imageUrl: fileUrl)!
        let imageLayer = Layer(name: fileUrl.lastPathComponent, textureProvider: textureProvider, device: device)
        previewScene.add(layer: imageLayer)

        updateTable()

        selectedLayer = imageLayer
        selectionView.selectedFrame = imageLayer.frame.denormalised(in: metalView.frame)
        selectionView.isHidden = false
    }

    func updateTable() {
        tableView.reloadData()
    }

    @IBAction func addPressed(_ sender: Any) {
        updateLiveSourceSubmenu()
        sourceMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return previewScene.layers.count
    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let layer = previewScene.layers[(previewScene.layers.count - 1) - row]

        if let layerView = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LayerPreviewCells"),
            owner: self
        ) as? LayerTableCell {
            layerView.configure(with: layer)
            return layerView
        }

        return nil
    }
}

extension ViewController: AirSightResizeViewDelegate {
    func selectionDidChanged(_ selectedRect: NSRect, resizeView: AirSightResizeView!) {
        if let layer = selectedLayer {
            layer.frame = NormalisedFrame(rect: selectedRect, parent: metalView.frame)
        }
    }
}
