//
//  Artisan.swift
//  ArtisanSample
//
//  Created by David Pettigrew on 4/7/15.
//  Copyright (c) 2015 Walmart Labs. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation

import Foundation

@IBDesignable
class Artisan {
    class func colorFromHTMLColor(hex: String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString

        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }

        if (cString.characters.count == 3) {
            var paddedString:String = ""
            let range = cString.startIndex ..< cString.endIndex
            cString.enumerateSubstringsInRange(range, options: .ByComposedCharacterSequences, { (substring, substringRange, enclosingRange, _) -> () in
                paddedString = paddedString + substring! + substring!
            })
            cString = paddedString
        }

        if (cString.characters.count == 6) {
            var rgbValue:UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }

        if (cString.characters.count == 8) {
            var rgbValue:UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }

        return .grayColor()
    }

    class func randomColorString() -> String {
        return String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255)
    }

    class func hexColorString(r r: UInt8, g: UInt8, b: UInt8) -> String {
        return String(format: "%02X", r) + String(format: "%02X", g) + String(format: "%02X", b)
    }

    class func radians(degrees: Double) -> Double {
        return degrees * M_PI/180
    }
}

class Drawer {
    var element: Element
    var drawFunc: (Element) -> Void

    init(element: Element, drawFunc: (Element) -> Void) {
        self.element = element
        self.drawFunc = drawFunc
    }
}

class Paper: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        self.init(frame: CGRectZero)
    }

    convenience init (x: Double, y: Double, width: Double, height:Double) {
        let rect:CGRect = CGRectMake(CGFloat(x), CGFloat(y),  CGFloat(width), CGFloat(height))
        self.init(frame: rect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBInspectable var fill: String = "666666" {
        didSet {
            backgroundColor = Artisan.colorFromHTMLColor(fill)
            setNeedsDisplay()
        }
    }

    var drawers = Array<Drawer>()

    override func drawRect(rect: CGRect) {
        for drawer in drawers {
            drawer.drawFunc(drawer.element)
        }
    }

    func ellipse(xCenter xCenter: Double, yCenter: Double, width: Double, height: Double) -> Ellipse {
        var ellipseOrigX = xCenter - width/2
        var ellipseOrigY = Double(bounds.origin.y) - height/2 + yCenter
        var ellipse: Ellipse = Ellipse(xCenter: ellipseOrigX, yCenter: ellipseOrigY, width: width, height: height)
        ellipse.paper = self
        layer.addSublayer(ellipse)
        // Ellipse Drawing
        func draw(element: Element) {
            let ellipse_: Ellipse = element as! Ellipse
            let rect = CGRectMake(CGFloat(ellipse_.xCenter), CGFloat(ellipse_.yCenter), CGFloat(ellipse_.width), CGFloat(ellipse_.height))
            ellipse_.path = UIBezierPath(ovalInRect: rect).CGPath
            ellipse_.fillColor = Artisan.colorFromHTMLColor(ellipse_.fill).CGColor
            ellipse_.strokeColor = Artisan.colorFromHTMLColor(ellipse_.stroke).CGColor
        }
        let drawer: Drawer = Drawer(element: ellipse, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return ellipse
    }

    func circle(xCenter xCenter: Double, yCenter: Double, r: Double) -> Ellipse {
        return ellipse(xCenter: xCenter, yCenter: yCenter, width: r * 2, height: r * 2)
    }

    func arc(xCenter xCenter: Double, yCenter: Double, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool) -> Path {
        var clockwiseStr: String = clockwise == true ? "1" : "0"
        var path: Path = Path(instructionString: "A \(xCenter) \(yCenter) \(radius) \(startAngle) \(endAngle) \(clockwiseStr)")
        path.paper = self
        layer.addSublayer(path)
        func draw(element: Element) {
            let path = element as! Path
            if path.fill == "" {
                path.fillColor = nil
            }
            else {
                path.fillColor = Artisan.colorFromHTMLColor(path.fill).CGColor
            }
            path.strokeColor = Artisan.colorFromHTMLColor(path.stroke).CGColor
        }
        let drawer: Drawer = Drawer(element: path as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return path
    }

    func rect(xOrigin xOrigin: Double, yOrigin: Double, width: Double, height: Double, cornerRadius: Double = 0) -> Rectangle {
        var rect: Rectangle = Rectangle(xOrigin: xOrigin, yOrigin: yOrigin, width: width, height: height)
        rect.cornerRadius = CGFloat(cornerRadius)
        rect.paper = self
        layer.addSublayer(rect)
        func draw(element: Element) {
            let rectangle: Rectangle = element as! Rectangle
            let rect = CGRectMake(CGFloat(rectangle.xOrigin), CGFloat(rectangle.yOrigin), CGFloat(rectangle.width), CGFloat(rectangle.height))
            // Rectangle Drawing
            rectangle.path = UIBezierPath(roundedRect: rect, cornerRadius: rectangle.cornerRadius).CGPath
            rectangle.fillColor = Artisan.colorFromHTMLColor(rectangle.fill).CGColor
            rectangle.strokeColor = Artisan.colorFromHTMLColor(rectangle.stroke).CGColor
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

    func image(src src: UIImage, xOrigin: Double, yOrigin: Double, width: Double, height: Double) -> Image {
        var image: Image = Image(src: src, xOrigin: xOrigin, yOrigin: yOrigin, width: width, height: height)
        image.paper = self
        func draw(element: Element) {
            let image = element as! Image
            let rect = CGRectMake(CGFloat(image.xOrigin), CGFloat(image.yOrigin), CGFloat(image.width), CGFloat(image.height))
            image.uiImage?.drawInRect(rect)
        }
        let drawer: Drawer = Drawer(element: image as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return image
    }

    func path(commands: String) -> Path {
        var path: Path = Path(instructionString: commands)
        path.paper = self
        layer.addSublayer(path)
        func draw(element: Element) {
            let path = element as! Path
            path.strokeColor = Artisan.colorFromHTMLColor(path.stroke).CGColor
            if path.fill == "" {
                path.fillColor = nil
            }
            else {
                path.fillColor = Artisan.colorFromHTMLColor(path.fill).CGColor
            }
        }
        let drawer: Drawer = Drawer(element: path as Element, drawFunc: draw)
        drawers.append(drawer)
        setNeedsDisplay()
        return path
    }
}

class Element : CAShapeLayer {
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

    override func actionForKey(event: String) -> CAAction? {
        if event == "path" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            return animation
        }
        return super.actionForKey(event)
    }
}

class Ellipse: Element  {
    var xCenter : Double = 0.0
    var yCenter: Double = 0.0
    var width : Double = 0.0
    var height: Double = 0.0
    var shapeLayer: CAShapeLayer?

    init (xCenter: Double, yCenter: Double, width: Double, height:Double) {
        self.xCenter = xCenter
        self.yCenter = yCenter
        self.width = width
        self.height = height
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(layer: AnyObject) {
        super.init(layer: layer)
    }
}

class Rectangle: Element {
    var xOrigin : Double = 0.0
    var yOrigin: Double = 0.0
    var width : Double = 0.0
    var height: Double = 0.0

    override var cornerRadius: CGFloat {
        didSet {
            paper?.setNeedsDisplay()
        }
    }

    init (xOrigin: Double, yOrigin: Double, width: Double, height:Double) {
        self.xOrigin = xOrigin
        self.yOrigin = yOrigin
        self.width = width
        self.height = height
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init(layer: AnyObject) {
        super.init(layer: layer)
    }
}

class Image: Element {
    var xOrigin : Double = 0.0
    var yOrigin: Double = 0.0
    var width : Double = 0.0
    var height: Double = 0.0
    var uiImage: UIImage?

    init (src: UIImage, xOrigin: Double, yOrigin: Double, width: Double, height:Double) {
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

    required override init(layer: AnyObject) {
        super.init(layer: layer)
    }
}

class Path: Element {
    var instructionString: String {
        didSet {
            self.path = Path.pathRefFor(self.instructionString)
        }
    }

    class func pathRefFor(instructionString: String) -> CGMutablePathRef {
        var cursorLoc: CGPoint = CGPointMake(0, 0)
        let pathRef = CGPathCreateMutable()
        var instructionStartIndex: Int = 0
        var instructions = instructionString.componentsSeparatedByString(" ")
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
                if let xNum = NSNumberFormatter().numberFromString(xStr), yNum = NSNumberFormatter().numberFromString(yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    CGPathMoveToPoint(pathRef, nil, x, y)
                    instructionStartIndex = instructionStartIndex + 3
                    cursorLoc = CGPointMake(x, y)
                }
            case "m": // moveto (relative) e.g. m 250 550
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete m path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NSNumberFormatter().numberFromString(xStr), yNum = NSNumberFormatter().numberFromString(yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    cursorLoc = CGPointMake(cursorLoc.x + x, cursorLoc.y + y)
                    CGPathMoveToPoint(pathRef, nil, cursorLoc.x, cursorLoc.y)
                    instructionStartIndex = instructionStartIndex + 3
                }
            case "L": // lineto (absolute) e.g. L 190 78
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete L path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NSNumberFormatter().numberFromString(xStr), yNum = NSNumberFormatter().numberFromString(yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    CGPathAddLineToPoint(pathRef, nil, x, y)
                    instructionStartIndex = instructionStartIndex + 3
                    cursorLoc = CGPointMake(x, y)
                }
            case "l": // lineto (relative) e.g. l 10 100
                if instructions.count <= instructionStartIndex+2 {
                    print("Encountered incomplete l path instruction")
                    break
                }
                let xStr = instructions[instructionStartIndex+1]
                let yStr = instructions[instructionStartIndex+2]
                if let xNum = NSNumberFormatter().numberFromString(xStr), yNum = NSNumberFormatter().numberFromString(yStr) {
                    let x: CGFloat = CGFloat(xNum)
                    let y: CGFloat = CGFloat(yNum)
                    cursorLoc = CGPointMake(cursorLoc.x + x, cursorLoc.y + y)
                    CGPathAddLineToPoint(pathRef, nil, cursorLoc.x, cursorLoc.y)
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
                if let xCenterNum = NSNumberFormatter().numberFromString(xCenterStr),
                    yCenterNum = NSNumberFormatter().numberFromString(yCenterStr),
                    radiusNum = NSNumberFormatter().numberFromString(radiusStr),
                    startAngleNum = NSNumberFormatter().numberFromString(startAngleStr),
                    endAngleNum = NSNumberFormatter().numberFromString(endAngleStr),
                    clockwiseNum = NSNumberFormatter().numberFromString(clockwiseStr)
                {
                    let x: CGFloat = CGFloat(xCenterNum)
                    let y: CGFloat = CGFloat(yCenterNum)
                    let radius: CGFloat = CGFloat(radiusNum)
                    let startAngle: CGFloat = CGFloat(Artisan.radians(Double(startAngleNum)))
                    let endAngle: CGFloat = CGFloat(Artisan.radians(Double(endAngleNum)))
                    let clockwise: Bool = Bool(clockwiseNum)
                    // inverted clockwise used, since for iOS "clockwise arc results in a counterclockwise arc after the transformation is applied" https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGContext/index.html#//apple_ref/c/func/CGContextAddArc
                    CGPathAddArc(pathRef, nil, x, y, radius, startAngle, endAngle, !clockwise)
                    instructionStartIndex = instructionStartIndex + 7
                }
            case "z", "Z": // closepath
                CGPathCloseSubpath(pathRef)
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
        self.path = Path.pathRefFor(self.instructionString)
    }

    required init?(coder aDecoder: NSCoder) {
        self.instructionString = ""
        super.init(coder: aDecoder)
    }

    required override init(layer: AnyObject) {
        self.instructionString = ""
        super.init(layer: layer)
    }
}

