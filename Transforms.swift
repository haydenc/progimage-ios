import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire

protocol Transform{
    func serialize() -> Dictionary<String, Any>
}

class Rotation: Transform{
    let angle: Double

    init(_ angle: Double){
        self.angle = angle
    }

    func serialize() -> Dictionary<String, Any> {
        return [
            "type": "rotate",
            "args": [self.angle]
        ]
    }
}

class Scale: Transform{
    let multiplier: Double

    init(_ multiplier: Double){
        self.multiplier = multiplier
    }

    func serialize() -> Dictionary<String, Any> {
        return [
            "type": "scale",
            "args": [self.multiplier]
        ]
    }
}

class Crop: Transform{
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int){
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    func serialize() -> Dictionary<String, Any> {
        return [
            "type": "scale",
            "args": [self.x, self.y, self.width, self.height]
        ]
    }
}
