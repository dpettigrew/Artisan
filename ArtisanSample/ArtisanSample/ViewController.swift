//
//  ViewController.swift
//  ArtisanSample
//
//  Created by David Pettigrew on 4/7/15.
//  Copyright (c) 2015 Walmart Labs. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
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

    func addEllipses(paper: Paper) {
        var xCenter = Double(self.view.center.x)
        var yCenter = Double(self.view.center.y)
        var width = Double(CGRectGetWidth(self.view.frame))
        var ellipse = paper.ellipse(xCenter: xCenter, yCenter: yCenter, width: width - 100, height: width)
        ellipse.fill = Artisan.hexColorString(r:200, g:200, b:34)
        ellipse.stroke = Artisan.hexColorString(r:155, g:0, b:34)

        delay(1, { () -> () in
            ellipse.fill = Artisan.hexColorString(r:100, g:100, b:134)
            ellipse.height = 45
            ellipse.width = 100
            ellipse.xCenter = 219
            ellipse.yCenter = 50
        })

        var ellipse2 = paper.ellipse(xCenter: 150, yCenter: 150, width: 200, height: 20)
        ellipse2.fill = randomColorString()

        var circle = paper.circle(xCenter: Double(paper.center.x), yCenter: Double(paper.center.y), r: 155)
        circle.fill = "#E91E63"
        circle.stroke = "#009688"
        circle.lineWidth = 5.0
        for(var i = 0; i < 5; i+=1) {
            var multiplier = i*5;
            var x:Double = Double(150) + Double((2*multiplier))
            var aCircle = paper.circle(xCenter: x, yCenter:Double(100 + multiplier), r:Double(50 - multiplier));
            aCircle.fill = randomColorString()
            aCircle.stroke = randomColorString()
        }
    }

    func addRects(paper: Paper) {
        var offset: Double = 50;
        for(var i = 0; i < 5; i+=1) {
            var rect = paper.rect(xOrigin: offset, yOrigin: offset, width: 50, height: 50, cornerRadius: Double(i))
            rect.fill = randomColorString()
            rect.lineWidth = CGFloat(i)
            rect.stroke = randomColorString()
            offset = offset + 50
        }

        var rect = paper.rect(xOrigin: 25, yOrigin: 225, width: 250, height: 250, cornerRadius: 5)
        rect.fill = randomColorString()
        rect.stroke = randomColorString()
    }

    func addImages(paper: Paper) {
        var image = UIImage(named: "photoHeader")
        assert(image != nil, "nil image")
        paper.image(src: image!, xOrigin: 0, yOrigin: Double(paper.bounds.size.height) - 140, width: 320, height: 140)
    }

    func addArcs(paper: Paper) {
        // method 1
        var arc1 = paper.arc(xCenter: 150, yCenter: 150, radius: 100, startAngle: 45, endAngle: 180, clockwise: true)
        arc1.stroke = "#76FF03"
        arc1.lineWidth = 7.5

        // method 2
        var arc2 = paper.path("a 100 100 25 0 180 1")
        arc2.stroke = "#9C27B0"
        arc2.lineWidth = 5.0
    }

    func addPaths(paper: Paper) {
        var tetronimo1 = paper.path("M 250 650 l 0 -50 l -50 0 l 0 -50 l -50 0 l 0 50 l -50 0 l 0 50 z")
        tetronimo1.stroke = "#f00"
        tetronimo1.fill = "#ff0"
        var tetronimo2 = paper.path("M 250 550 m 0 -150 l 0 -50 l -50 0 l 0 -50 l -50 0 l 0 50 l -50 0 l 0 50 z")
        tetronimo2.stroke = "#f0f"
        tetronimo2.fill = "#1fe"

        // Add a star shape
        var star = paper.path("M 100 10 L 40 198 L 190 78 L 10 78 L 160 198 z")
        star.stroke = "#673AB7"
        star.fill = "#FF9800"

        var triangle = paper.path("M 150 250 l -75 200 l 150 0 Z")
        triangle.stroke = "#4CAF50"
        triangle.fill = "#FF5722"

        // animate it to a triangle
        delay(1.0, { () -> () in
            star.instructionString = ("M 150 50 l -75 200 l 150 0 Z")
            star.stroke = "#342"
            star.fill = "#f49"
        })
    }

    override func viewDidAppear(animated: Bool) {
        // setup a Paper object
        var paper: Paper = Paper(frame: self.view.bounds)
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
