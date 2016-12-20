//
//  Annotation.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-19.
//
//

import UIKit

enum AnnotType {
    case light
    case sound
    case note
}

class Annot: UIView {
    
    var annotDot = UIView()
    var annotBox = UIView()
    var annotColor = UIColor()
    var boxWidth = CGFloat()
    var annotDotContainer = UIView()
    
    init(dotLocation: CGPoint, rect: CGRect, type: AnnotType, allowEdits: Bool) {
        super.init(frame: rect)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        let boxXOffset: CGFloat = 25
        self.boxWidth = self.bounds.size.width * 0.2
        
        if type == AnnotType.light {
            self.annotColor = .blue
        } else if type == AnnotType.sound {
            self.annotColor = .orange
        } else {
            self.annotColor = .gray
        }
        
        // create Annotation Dot
        
        annotDotContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        annotDotContainer.backgroundColor = UIColor.clear
        annotDotContainer.center = dotLocation
        
        annotDot = UIView(frame: CGRect(x: 12.5, y: 12.5, width: 15, height: 15))
        annotDot.backgroundColor = self.annotColor.withAlphaComponent(1)
        annotDot.layer.cornerRadius = 7.5
        
        self.addSubview(annotDotContainer)
        annotDotContainer.addSubview(annotDot)
        
        // set up Annotation Box frame
        
        annotBox = UIView(frame: CGRect.zero)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if dotLocation.x > rect.size.width / 2 {
            x = rect.size.width - self.boxWidth + boxXOffset
        } else {
            x = 0 - boxXOffset
        }
        
        if dotLocation.y < 50 {
            y = 0
        } else if dotLocation.y > rect.size.height - 50{
            y = rect.size.height - 100
        } else {
            y = dotLocation.y - 50
        }
        
        annotBox.frame = CGRect(x: x, y: y, width: self.boxWidth, height: 100)
        
        // colors, corners, borders
        
        annotBox.backgroundColor = self.annotColor.withAlphaComponent(0.2)
        annotBox.layer.cornerRadius = 20
        annotBox.layer.borderColor = self.annotColor.withAlphaComponent(0.5).cgColor
        annotBox.layer.borderWidth = 4

        self.addSubview(annotBox)
        
        if allowEdits {
            self.setupGestures()
        }
    }
    
    func setupGestures() {
        let dotPan = UIPanGestureRecognizer(target: self, action: #selector(self.moveAnnotDot(_:)))
        self.annotDotContainer.addGestureRecognizer(dotPan)
        self.annotDotContainer.isUserInteractionEnabled = true
        
        let boxTap = UITapGestureRecognizer(target: self, action: #selector(self.editAnnotBox(_:)))
        self.annotBox.addGestureRecognizer(boxTap)
        self.annotDotContainer.isUserInteractionEnabled = true
    }
    
    func moveAnnotDot(_ sender: UIPanGestureRecognizer) {
        self.annotDotContainer.center = sender.location(in: self)
        setNeedsDisplay()
    }
    
    func editAnnotBox(_ sender: UIPanGestureRecognizer) {
        let deleteBox = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        deleteBox.backgroundColor = UIColor.red
        deleteBox.tintColor = UIColor.white
        deleteBox.titleLabel?.text = "X"
        deleteBox.titleLabel?.font = UIFont(name: "Avenir Next", size: 12)
        deleteBox.center = CGPoint(x: self.annotBox.frame.size.width - 25, y: self.annotBox.frame.origin.y)
        self.addSubview(deleteBox)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.annotBox.frame.contains(point) || self.annotDotContainer.frame.contains(point) {
            return true
        }
        return false
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.setStrokeColor(self.annotColor.withAlphaComponent(0.4).cgColor);
        ctx!.setLineWidth(1);
        ctx?.move(to: self.annotDotContainer.center)
        if annotBox.frame.origin.x > 0 {
           ctx?.addLine(to: CGPoint(x: self.annotBox.center.x - self.annotBox.frame.size.width / 2, y: self.annotBox.center.y))
        } else {
            ctx?.addLine(to: CGPoint(x: self.annotBox.center.x + self.annotBox.frame.size.width / 2, y: self.annotBox.center.y))
        }
        ctx!.strokePath()
            
    }

}
