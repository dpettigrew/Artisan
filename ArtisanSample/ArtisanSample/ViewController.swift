//
//  ViewController.swift
//  ArtisanSample
//
//  Created by David Pettigrew on 4/7/15.
//  Copyright (c) 2017 LifeCentrics. All rights reserved.
//

import UIKit

func delay(_ delay: Double, closure: @escaping () -> Void) {
    let delay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delay) {
        closure()
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addEllipses(_ paper: Paper) {
        let xCenter = Double(self.view.center.x)
        let yCenter = Double(self.view.center.y)
        let width = Double(self.view.frame.width)
        let ellipse = paper.ellipse(xCenter: xCenter, yCenter: yCenter, width: width - 100, height: width)
        ellipse.fill = Artisan.hexColorString(red: 200, green: 200, blue: 34)
        ellipse.stroke = Artisan.hexColorString(red: 155, green: 0, blue: 34)

        delay(1, closure: { () -> Void in
            ellipse.fill = Artisan.hexColorString(red:100, green: 100, blue: 134)
            ellipse.height = 45
            ellipse.width = 100
            ellipse.xCenter = 219
            ellipse.yCenter = 50
        })

        let ellipse2 = paper.ellipse(xCenter: 150, yCenter: 150, width: 200, height: 20)
        ellipse2.fill = randomColorString()

        let circle = paper.circle(xCenter: Double(paper.center.x), yCenter: Double(paper.center.y), radius: 155)
        circle.fill = "#E91E63"
        circle.stroke = "#009688"
        circle.lineWidth = 5.0
        for i in 0..<5 {
            let multiplier = i*5
            let x: Double = Double(150) + Double((2*multiplier))
            let aCircle = paper.circle(xCenter: x, yCenter:Double(100 + multiplier), radius:Double(50 - multiplier))
            aCircle.fill = randomColorString()
            aCircle.stroke = randomColorString()
        }
    }

    func addRects(_ paper: Paper) {
        var offset: Double = 50
        for i in 0..<5 {
            let rect = paper.rect(xOrigin: offset, yOrigin: offset, width: 50, height: 50, cornerRadius: Double(i))
            rect.fill = randomColorString()
            rect.lineWidth = CGFloat(i)
            rect.stroke = randomColorString()
            offset = offset + 50
        }

        let rect = paper.rect(xOrigin: 25, yOrigin: 225, width: 250, height: 250, cornerRadius: 5)
        rect.fill = randomColorString()
        rect.stroke = randomColorString()
    }

    func addImages(_ paper: Paper) {
        let image = UIImage(named: "photoHeader")
        assert(image != nil, "nil image")
        let _ = paper.image(src: image!, xOrigin: 0, yOrigin: Double(paper.bounds.size.height) - 140, width: 320, height: 140)
    }

    func addArcs(_ paper: Paper) {
        // method 1
        let arc1 = paper.arc(xCenter: 150, yCenter: 150, radius: 100, startAngle: 45, endAngle: 180, clockwise: true)
        arc1.stroke = "#76FF03"
        arc1.lineWidth = 7.5

        // method 2
        let arc2 = paper.path("a 100 100 25 0 180 1")
        arc2.stroke = "#9C27B0"
        arc2.lineWidth = 5.0
    }

    func addPaths(_ paper: Paper) {
        let tetronimo1 = paper.path("M 250 650 l 0 -50 l -50 0 l 0 -50 l -50 0 l 0 50 l -50 0 l 0 50 z")
        tetronimo1.stroke = "#f00"
        tetronimo1.fill = "#ff0"
        let tetronimo2 = paper.path("M 250 550 m 0 -150 l 0 -50 l -50 0 l 0 -50 l -50 0 l 0 50 l -50 0 l 0 50 z")
        tetronimo2.stroke = "#f0f"
        tetronimo2.fill = "#1fe"

        // Add a star shape
        let star = paper.path("M 100 10 L 40 198 L 190 78 L 10 78 L 160 198 z")
        star.stroke = "#673AB7"
        star.fill = "#FF9800"

        let triangle = paper.path("M 150 250 l -75 200 l 150 0 Z")
        triangle.stroke = "#4CAF50"
        triangle.fill = "#FF5722"

        // animate it to a triangle
        delay(1.0, closure: { () -> Void in
            star.instructionString = ("M 150 50 l -75 200 l 150 0 Z")
            star.stroke = "#342"
            star.fill = "#f49"
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        // setup a Paper object
        let paper: Paper = Paper(frame: self.view.bounds)
        paper.fill = "#eee"
        self.view.addSubview(paper)

        // add things to the paper
        addEllipses(paper)
        addRects(paper)
        addImages(paper)
        addPaths(paper)
        addArcs(paper)
    }

    func randomColorString() -> String {
        return String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255) + String(format: "%02X", arc4random()%255) + "FF"
    }
}
