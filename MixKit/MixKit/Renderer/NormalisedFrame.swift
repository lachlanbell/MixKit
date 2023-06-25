//
//  NormalisedFrame.swift
//  MixKit
//
//  Created by Lachlan Bell on 10/9/20.
//  Copyright © 2020 Lachlan Bell.
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

public struct NormalisedFrame {
    public var minX: Float
    public var maxX: Float
    public var minY: Float
    public var maxY: Float

    public init(minX: Float, minY: Float, maxX: Float, maxY: Float) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
}
