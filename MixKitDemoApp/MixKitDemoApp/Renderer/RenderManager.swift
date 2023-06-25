//
//  RenderManager.swift
//  MixKitDemoApp
//
//  Created by Lachlan Bell on 25/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

import Foundation
import MetalKit
import MixKit

class RenderManager: DisplayTimerDelegate {

    static let shared = RenderManager()

    private var dependents: [MTKView] = []
    private var pendingDrawRequest: DispatchWorkItem?

    let drawQueue: DispatchQueue = DispatchQueue(label: "mixkit-draw", qos: .userInteractive, attributes: [])
    let timer: DisplayTimer

    init() {
        timer = DisplayTimer()
        timer.delegate = self
    }

    func addDependentView(_ view: MTKView) {
        dependents.append(view)
    }

    func drawFrame(forTime outputTime: UnsafePointer<CVTimeStamp>) {
        pendingDrawRequest?.cancel()

        let drawRequest = DispatchWorkItem { [weak self] in
            self?.dependents.forEach {
                $0.draw()
            }
        }

        pendingDrawRequest = drawRequest
        drawQueue.async(execute: drawRequest)
    }
}
