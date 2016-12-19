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

class Annot: NSObject {
    
    var annotDot = UIView()
    var annotBox = UIView()
    var annotLine = UIView()
    
    init(dotLocation: CGPoint, rect: CGRect, type: AnnotType) {
        super.init()
        
        let annotColor: UIColor!
        let boxXOffset: CGFloat = 25
        
        if type == AnnotType.light {
            annotColor = UIColor.blue
        } else if type == AnnotType.sound {
            annotColor = UIColor.orange
        } else {
            annotColor = UIColor.gray
        }
        
        // create Annotation Dot
        
        annotDot = UIView(frame: CGRect(x: dotLocation.x - 8, y: dotLocation.y - 8, width: 16, height: 16))
        annotDot.backgroundColor = annotColor.withAlphaComponent(0.4)
        
        // set up Annotation Box frame
        
        annotBox = UIView(frame: CGRect.zero)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if dotLocation.x > rect.size.width / 2 {
            x = rect.size.width - 150 + boxXOffset
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
        
        annotBox.frame = CGRect(x: x, y: y, width: 150, height: 100)
        
        // colors, corners, borders
        
        annotBox.backgroundColor = annotColor.withAlphaComponent(0.2)
        annotBox.layer.cornerRadius = 20
        annotBox.layer.borderColor = annotColor.withAlphaComponent(0.5).cgColor
        annotBox.layer.borderWidth = 4
        
        // create annotLine
        
//        x =
//        
//        
//        self.annotLine = UIView(frame: CGRect)
        
    }
    
    

}
