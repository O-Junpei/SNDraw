//
//  SNPathBuilder.swift
//  SNDraw
//
//  Created by satoshi on 8/6/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

public struct SNPathBuilder {
    public var minSegment:CGFloat
    public fileprivate(set) var elements:[SNPathElement]
    
    fileprivate var path = CGMutablePath()
    fileprivate var length = 0 as CGFloat
    fileprivate var anchor = CGPoint.zero // last anchor point
    fileprivate var last = CGPoint.zero // last touch point
    fileprivate var delta = CGPoint.zero // last movement to compare against to detect a sharp turn
    fileprivate var fEdge = true //either the begging or the turning point

    init(minSegment:CGFloat) {
        self.elements = [SNPathElement]()
        self.minSegment = minSegment
    }
    
    public mutating func start(_ pt:CGPoint) -> CGPath {
        path = CGMutablePath()
        path.move(to: pt)
        elements = [SNMove(x: pt.x, y: pt.y)]
        anchor = pt
        last = pt
        fEdge = true
        length = 0.0
        return path
    }

    public mutating func move(_ pt:CGPoint) -> CGPath? {
        var pathToReturn:CGPath?
        let d = pt.delta(last)
        length += sqrt(d.dotProduct(d))
        if length > minSegment {
            // Detected enough movement. Add a quad segment, if we are not at the edge.
            if !fEdge {
                let ptMid = anchor.middle(pt)
                path.addQuadCurve(to: pt, control: anchor)
                elements.append(SNQuadCurve(cpx: anchor.x, cpy: anchor.y, x: ptMid.x, y: ptMid.y))
                pathToReturn = path
            }
            delta = pt.delta(anchor)
            anchor = pt
            fEdge = false
            length = 0.0
        } else if !fEdge && delta.dotProduct(d) < 0 {
            // Detected a "turning back". Add a quard segment, and turn on the fEdge flag.
            processLast()
            pathToReturn = path
            anchor = last // matter for delta in "Neither" case (does not matter for QuadCurve, see above)
            fEdge = true
            length = 0.0
        } else {
            // Neigher. Return the path with a line to the current point as a transient path.
            let pathTemp = path.mutableCopy()
            pathTemp?.addLine(to: pt)
            pathToReturn = pathTemp
            delta = pt.delta(anchor)
        }
        last = pt
        
        return pathToReturn
    }
    
    fileprivate mutating func processLast() {
        if !fEdge, let quad = elements.last as? SNQuadCurve {
            elements.removeLast()
            elements.append(SNQuadCurve(cp: quad.cp, pt: last))
            path = SNPath.pathFrom(elements)
        } else {
            path.addQuadCurve(to: last, control: anchor)
            elements.append(SNQuadCurve(cp: anchor, pt: last))
        }
    }
    
    public mutating func end() -> CGPath {
        processLast()
        return path
    }
}
