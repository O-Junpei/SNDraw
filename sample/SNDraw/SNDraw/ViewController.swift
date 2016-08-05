//
//  ViewController.swift
//  SNDraw
//
//  Created by satoshi on 8/2/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var drawView:SNDrawView?
    var layers = [CALayer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clear() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
    }
    
    @IBAction func slide(slider:UISlider) {
        drawView?.minSegment = CGFloat(slider.value)
    }
}

extension ViewController : SNDrawViewDelegate {
    func didComplete(elements:[SNPathElement]) -> Bool {
        print("complete", elements.count)

        let layerCurve = CAShapeLayer()
        layerCurve.path = SNPath.pathFrom(elements)
        layerCurve.lineWidth = 1
        layerCurve.fillColor = UIColor.clearColor().CGColor
        layerCurve.strokeColor = UIColor.greenColor().CGColor
        self.view.layer.addSublayer(layerCurve)
        layers.append(layerCurve)

        let layerLine = CAShapeLayer()
        layerLine.path = SNPath.polyPathFrom(elements)
        layerLine.lineWidth = 1
        layerLine.fillColor = UIColor.clearColor().CGColor
        layerLine.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.2).CGColor
        self.view.layer.addSublayer(layerLine)
        layers.append(layerLine)

        return true
    }
}

