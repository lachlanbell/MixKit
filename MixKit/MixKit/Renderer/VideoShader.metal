//
//  VideoShader.metal
//  MixKit
//
//  Created by Lachlan Bell on 21/11/19.
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

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0)]];
    float4 color [[ attribute(1) ]];
    float2 textureCoords [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoords;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]]) {
    VertexOut vertexOut;

    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoords = vertexIn.textureCoords;

    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}

fragment half4 textured_fragment(VertexOut vertexIn [[ stage_in ]],
                                 texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    float4 color = texture.sample(defaultSampler, vertexIn.textureCoords);

    if(color.a == 0.0) { discard_fragment(); }

    return half4(color.r, color.g, color.b, color.a);
}
