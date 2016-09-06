//
//  ShapeType.swift
//  GeometryFighter
//
//  Created by Thomas on 2016-09-06.
//  Copyright © 2016 Thomas Månsson. All rights reserved.
//

import Foundation

// 1
public enum ShapeType:Int {
    case Box = 0
    case Sphere
    case Pyramid
    case Torus
    case Capsule
    case Cylinder
    case Cone
    case Tube
    // 2
    static func random() -> ShapeType {
        let maxValue = Tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    } }
