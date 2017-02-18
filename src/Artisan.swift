//
//  Artisan.swift
//
//  Created by David Pettigrew on 4/7/15.
//  Copyright (c) 2015 LifeCentrics. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation

import Foundation

@IBDesignable
class Artisan {
    class func color(fromHexRGB hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
        }

        if (cString.characters.count == 3) {
            var paddedString: String = ""
            let range = cString.characters.startIndex..<cString.characters.endIndex
            cString.enumerateSubstrings(in: range, options: .byComposedCharacterSequences, { (substring, _, _, _) in
                paddedString = paddedString + substring! + substring!
            })
            cString = paddedString
        }

        if (cString.characters.count == 6) {
            var rgbValue: UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }

        if (cString.characters.count == 8) {
            var rgbValue: UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }

        return .gray
    }

    class func randomColorString() -> String {
        return String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255)
    }

    class func hexColorString(r: UInt8, g: UInt8, b: UInt8) -> String {
        return String(format: "%02X", r) + String(format: "%02X", g) + String(format: "%02X", b)
    }

    class func radians(_ degrees: Double) -> Double {
        return degrees * M_PI/180
    }
}

class Drawer {
    var element: Element
    var drawFunc: (Element) -> Void

    init(element: Element, drawFunc: @escaping (Element) -> Void) {
        self.element = element
        self.drawFunc = drawFunc
    }
}

class Paper: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    convenience init (x: Double, y: Double, width: Double, height: Double) {
        let rect: CGRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
        self.init(frame: rect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBInspectable var fill: String = "666666" {
        didSet {
            backgroundColor = Artisan.color(fromHexRGB: fill)
            setNeedsDisplay()
        }
    }

    var drawers = Array<Drawer>()

    override func draw(_ rect: CGRect) {
        for drawer in drawers {
            drawer.drawFunc(drawer.element)
        }
    }

    func ellipse(xCenter: Double, yCenter: Double, width: Double, height: Double) -> Ellipse {
        var ellipseOrigX = xCenter - width/2
        var ellipseOrigY = Double(bounds.origin.y) - height/2 + yCenter
        var ellipse: Ellipse = Ellipse(xCenter: ellipseOrigX, yCenter: ellipseOrigY, width: width, height: height)
        ellipse.paper = self
        layer.addSublayer(ellipse)
        // Ellipse Drawing
        func draw(_ element: Element) {
            let ellipse_: Ellipse = element as! Ellipse
            let rect = CGRect(x: CGFloat(ellipse_.xCenter), y: CGFloat(ellipse_.yCenter), width: CGFloat(ellipse_.width), height: CGFloat(ellipse_.height))
            ellipse_.path = UIBezierPath(ovalIn: rect).cgPath
            ellipse_.fillColor = Artisan.color(fromHexRGB: ellipse_.fill).cgColor
            ellipse_.strokeColor = Artisan.color(fromHexRGB: ellipse_.stroke).cgColor
        }
        let drawer: Drawer = Drawer(element: ellipse, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return ellipse
    }

    func circle(xCenter: Double, yCenter: Double, r: Double) -> Ellipse {
        return ellipse(xCenter: xCenter, yCenter: yCenter, width: r * 2, height: r * 2)
    }

    func arc(xCenter: Double, yCenter: Double, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool) -> Path {
        var clockwiseStr: String = clockwise == true ? "1" : "0"
        var path: Path = Path(instructionString: "A \(xCenter) \(yCenter) \(radius) \(startAngle) \(endAngle) \(clockwiseStr)")
        path.paper = self
        layer.addSublayer(path)
        func draw(_ element: Element) {
            let path = element as! Path
            if path.fill == "" {
                path.fillColor = nil
            }
            else {
                path.fillColor = Artisan.color(fromHexRGB: path.fill).cgColor
            }
            path.strokeColor = Artisan.color(fromHexRGB: path.stroke).cgColor
        }
        let drawer: Drawer = Drawer(element: path as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return path
    }

    func rect(xOrigin: Double, yOrigin: Double, width: Double, height: Double, cornerRadius: Double = 0) -> Rectangle {
        var rect: Rectangle = Rectangle(xOrigin: xOrigin, yOrigin: yOrigin, width: width, height: height)
        rect.cornerRadius = CGFloat(cornerRadius)
        rect.paper = self
        layer.addSublayer(rect)
        func draw(_ element: Element) {
            let rectangle: Rectangle = element as! Rectangle
            let rect = CGRect(x: CGFloat(rectangle.xOrigin), y: CGFloat(rectangle.yOrigin), width: CGFloat(rectangle.width), height: CGFloat(rectangle.height))
            // Rectangle Drawing
            rectangle.path = UIBezierPath(roundedRect: rect, cornerRadius: rectangle.cornerRadius).cgPath
            rectangle.fillColor = Artisan.color(fromHexRGB: rectangle.fill).cgColor
            rectangle.strokeColor = Artisan.color(fromHexRGB: rectangle.stroke).cgColor
        }
        let drawer: Drawer = Drawer(element: rect, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return rect
    }

    func clear() {
        drawers = Array<Drawer>()
        setNeedsDisplay()
    }

    func image(src: UIImage, xOrigin: Double, yOrigin: Double, width: Double, height: Double) -> Image {
        var image: Image = Image(src: src, xOrigin: xOrigin, yOrigin: yOrigin, width: width, height: height)
        image.paper = self
        func draw(_ element: Element) {
            let image = element as! Image
            let rect = CGRect(x: CGFloat(image.xOrigin), y: CGFloat(image.yOrigin), width: CGFloat(image.width), height: CGFloat(image.height))
            image.uiImage?.draw(in: rect)
        }
        let drawer: Drawer = Drawer(element: image as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return image
    }

    func path(_ commands: String) -> Path {
        var path: Path = Path(instructionString: commands)
        path.paper = self
        layer.addSublayer(path)
        func draw(_ element: Element) {
            let path = element as! Path
            path.strokeColor = Artisan.color(fromHexRGB: path.stroke).cgColor
            if path.fill == "" {
                path.fillColor = nil
            }
            else {
                path.fillColor = Artisan.color(fromHexRGB: path.fill).cgColor
            }
        }
        let drawer: Drawer = Drawer(element: path as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return path
    }
}

class Element: CAShapeLayer {
    var paper: Paper?

    var stroke: String = "222222" {
        didSet {
            paper?.setNeedsDisplay()
        }
    }

    var fill: String = "" {
        didSet {
            paper?.setNeedsDisplay()
        }
    }

    override var lineWidth: CGFloat {
        didSet {
            paper?.setNeedsDisplay()
        }
    }

    override func action(forKey event: String) -> CAAction? {
        if event == "path" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            return animation
        }
        return super.action(forKey: event)
    }
}

class Ellipse: Element {
    var xCenter: Double = 0.0
    var yCenter: Double = 0.0
    var width: Double = 0.0
    var height: Double = 0.0
    var shapeLayer: CAShapeLayer?

    init (xCenter: Double, yCenter: Double, width: Double, height: Double) {
        self.xCenter = xCenter
        self.yCenter = yCenter
        self.width = width
        self.height = height
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(layer: Any) {
        super.init(layer: layer)
    }
}

class Rectangle: Element {
    var xOrigin: Double = 0.0
    var yOrigin: Double = 0.0
    var width: Double = 0.0
    var height: Double = 0.0

    override var cornerRadius: CGFloat {
        didSet {
            paper?.setNeedsDisplay()
        }
    }

    init (xOrigin: Double, yOrigin: Double, width: Double, height: Double) {
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self.width = width
        self.height = height
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(layer: Any) {
        super.init(layer: layer)
    }
}

class Image: Element {
    var xOrigin: Double = 0.0
    var yOrigin: Double = 0.0
    var width: Double = 0.0
    var height: Double = 0.0
    var uiImage: UIImage?

    init (src: UIImage, xOrigin: Double, yOrigin: Double, width: Double, height: Double) {
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self.width = width
        self.height = height
        self.uiImage = src
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(layer: Any) {
        super.init(layer: layer)
    }
}

class Path: Element {
    var instructionString: String {
        didSet {
            self.path = Path.pathRef(for: self.instructionString)
        }
    }

    class func pathRef(for instructionString: String) -> CGMutablePath {
        var cursorLoc: CGPoint = CGPoint(x: 0, y: 0)
        let pathRef = CGMutablePath()
        var instructionStartIndex: Int = 0
        var instructions = instructionString.components(separatedBy: " ")
        for i in 0..<instructions.count {
            if i < instructionStartIndex {
                continue
            }
            let instruction = instructions[i]
            switch instruction {
            case "M": // moveto (absolute) e.g. M 250 550
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete M path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NumberFormatter().number(from: xStr),
                    let yNum = NumberFormatter().number(from: yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    pathRef.move(to: CGPoint(x: x, y: y))
                    instructionStartIndex = instructionStartIndex + 3
                    cursorLoc = CGPoint(x: x, y: y)
                }
            case "m": // moveto (relative) e.g. m 250 550
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete m path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NumberFormatter().number(from: xStr),
                    let yNum = NumberFormatter().number(from: yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    cursorLoc = CGPoint(x: cursorLoc.x + x, y: cursorLoc.y + y)
                    pathRef.move(to: CGPoint(x: cursorLoc.x, y: cursorLoc.y))
                    instructionStartIndex = instructionStartIndex + 3
                }
            case "L": // lineto (absolute) e.g. L 190 78
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete L path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NumberFormatter().number(from: xStr),
                    let yNum = NumberFormatter().number(from: yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    pathRef.addLine(to: CGPoint(x: x, y: y))
                    instructionStartIndex = instructionStartIndex + 3
                    cursorLoc = CGPoint(x: x, y: y)
                }
            case "l": // lineto (relative) e.g. l 10 100
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete l path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NumberFormatter().number(from: xStr),
                    let yNum = NumberFormatter().number(from: yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    cursorLoc = CGPoint(x: cursorLoc.x + x, y: cursorLoc.y + y)
                    pathRef.addLine(to: CGPoint(x: cursorLoc.x, y: cursorLoc.y))
                    instructionStartIndex = instructionStartIndex + 3
                }
            case "a", "A": // arc e.g. a 100 100 25 180 270 1
                if instructions.count <= instructionStartIndex+6 {
                    print("Encountered incomplete a or A path instruction")
                    break
                }
                let xCenterStr = instructions[instructionStartIndex+1]
                let yCenterStr = instructions[instructionStartIndex+2]
                let radiusStr = instructions[instructionStartIndex+3]
                let startAngleStr = instructions[instructionStartIndex+4]
                let endAngleStr = instructions[instructionStartIndex+5]
                let clockwiseStr = instructions[instructionStartIndex+6]
                if let xCenterNum = NumberFormatter().number(from: xCenterStr),
                    let yCenterNum = NumberFormatter().number(from: yCenterStr),
                    let radiusNum = NumberFormatter().number(from: radiusStr),
                    let startAngleNum = NumberFormatter().number(from: startAngleStr),
                    let endAngleNum = NumberFormatter().number(from: endAngleStr),
                    let clockwiseNum = NumberFormatter().number(from: clockwiseStr) {
                    let x: CGFloat = CGFloat(xCenterNum)
                    let y: CGFloat = CGFloat(yCenterNum)
                    let radius: CGFloat = CGFloat(radiusNum)
                    let startAngle: CGFloat = CGFloat(Artisan.radians(Double(startAngleNum)))
                    let endAngle: CGFloat = CGFloat(Artisan.radians(Double(endAngleNum)))
                    let clockwise: Bool = Bool(clockwiseNum)
                    // inverted clockwise used, since for iOS "clockwise arc results in a counterclockwise arc after the transformation is applied" https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGContext/index.html#//apple_ref/c/func/CGContextAddArc
                    pathRef.addArc(center: CGPoint(x: x, y: y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: !clockwise)
                    instructionStartIndex = instructionStartIndex + 7
                }
            case "z", "Z": // closepath
                pathRef.closeSubpath()
                instructionStartIndex = instructionStartIndex + 2
            default:
                print("Failed to process path instruction")
            }
        }
        return pathRef
    }

    init(instructionString: String) {
        self.instructionString = instructionString
        super.init()
        self.path = Path.pathRef(for: self.instructionString)
    }

    required init?(coder aDecoder: NSCoder) {
        self.instructionString = ""
        super.init(coder: aDecoder)
    }

    required override init(layer: Any) {
        self.instructionString = ""
        super.init(layer: layer)
    }
}
