# 🎛️ MixKit

MixKit is a realtime video compositing framework built on Metal, that formed the core of a live video mixing app I was writing for the Mac.

## Demo

Below is a demo of building a simple presentation scene in MixKit, from two live Syphon sources and a static image:

https://github.com/lachlanbell/MixKit/assets/19360256/d9eb8adc-12ed-4797-b10b-61d9b2b7f7a5


## Overview

### Texture Providers

Video frames are provided to MixKit by *texture providers*. Texture providers conform to a simple API:

```swift
@objc public protocol TextureProvider {
    /// Get the next frame as a Metal texture
    func nextFrame() -> MTLTexture?

    /// Start providing textures (optional)
    func start()

    /// Stop providing textures (optional)
    func stop()
}
```

MixKit was designed to be dynamically extensible by plugins that provide implementations of the `TextureProvider` protocol. An example texture provider library for [Syphon](https://syphon.github.io), the excellent [IOSurface](https://developer.apple.com/documentation/iosurface)-backed technology for sharing frames between macOS video apps, is included with the demo app.

### Layers
The fundamental unit for MixKit renders is a *layer*. Layers have a frame (normalised between -1 and 1 relative to a parent’s coordinate space), a texture provider, and an associated GPU device:
```swift
public class Layer: Renderable {
    public var frame: NormalisedFrame

    public init(
        name: String,
        textureProvider: TextureProvider,
        device: MTLDevice
    )
}
```

### Scenes
Multiple layers can be composed into a *scene*. Layers are composited in the order they appear in the scene’s `layers` array.

```swift
public class Scene: Renderable {
    public var layers: [Layer]
}
```

### Rendering

MixKit provides a `TextureViewRenderer` class, which handles all rendering of a `Scene` to a MetalKit `MTKView`. For example, intialising a simple render output looks like:

```swift
let scene = Scene()
scene.addLayer(…)

let outputView = MTKView(
    frame: self.view.bounds,
    device: MTLCreateSystemDefaultDevice()
)

let renderer = TextureViewRenderer(view: outputView)
renderer.scene = scene
```

Internal rendering behaviour is easy to change or extend. MixKit types implement the basic `Renderable` protocol, which defines an object that can encode render commands to a Metal command bufer:
```swift
protocol Renderable {
    /// Encode commands necessary to render the `Renderable`
    func render(commandEncoder: MTLRenderCommandEncoder)
}
```

## Disclaimer of Quality

I wrote MixKit as a 16-year-old uni student that hadn't yet learnt graphics programming for realsies, and as such there are some naïve mistakes in it 😛. That said, it performs well and I think the fundamental design holds up alright. Hopefully it can be a helpful jumping off point if you’re exploring the problem space.

## License
MixKit is available under the Apache 2.0 License. The demo app uses a control licensed under the GPLv3, and therefore its code is also available under the GPLv3.
