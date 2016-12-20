//
//  Annotation.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-19.
//
//

import UIKit

enum AnnotType: Int {
    case light
    case sound
    case note
}

class Annot: UIView {
    
    // MARK: Properties
    
    var annotDot = UIView()
    var annotBox = UIView()
    var annotColor = UIColor()
    var annotDotContainer = UIView()
    var deleteButton = UIButton()
    var resizeHandle = UIView()
    var instructionOverlay = UIView()
    var tapToEditLabel = UILabel()
    var dragToMoveLabel = UILabel()
    var boxWidth = CGFloat()
    let boxOffset: CGFloat = 25
    var editMode: Bool = false
    var annot: Annotation? = nil
    var pageSize = CGRect.zero
    
    // MARK: Inits
    
    init(pageNum: Int, dotLocation: CGPoint, rect: CGRect, type: AnnotType, allowEdits: Bool) {
        super.init(frame: rect)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.boxWidth = self.bounds.size.width * 0.2 + boxOffset
        self.pageSize = rect
        
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
            x = rect.size.width - self.boxWidth + boxOffset
        } else {
            x = 0 - boxOffset
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
        annotBox.clipsToBounds = true

        self.addSubview(annotBox)
        
        if allowEdits {
            self.setupGestures()
        }
        
        // Save in Core Data
        
        self.annot = DataManager.share.makeAnnotation(page: pageNum+1,
                                                      type: type.rawValue,
                                                      boxW: self.mapToX(value: self.annotBox.frame.size.width),
                                                      boxH: self.mapToY(value: self.annotBox.frame.size.height),
                                                      boxX: self.mapToX(value: self.annotBox.frame.origin.x),
                                                      boxY: self.mapToY(value: self.annotBox.frame.origin.y),
                                                      dotX: self.mapToX(value: self.annotDot.frame.origin.x),
                                                      dotY: self.mapToY(value: self.annotBox.frame.origin.y))
        
        self.makeAnnotDesc()
    }
    
    func makeAnnotDesc() {
        self.annot?.cueDescription = "HAHAHAHAHAHAHA"
        DataManager.share.saveContext()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gestures and actions
    
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
    
    func editAnnotBox(_ sender: UITapGestureRecognizer) {
        self.editMode = true
        
        self.layoutInstructionOverlay()
        self.annotBox.addSubview(self.instructionOverlay)
        
        self.layoutDeleteButton()
        self.addSubview(self.deleteButton)
        
        self.layoutResizeHandle()
        self.addSubview(self.resizeHandle)
        
        superview?.bringSubview(toFront: self)
        
        let endEdit = UITapGestureRecognizer(target: self, action: #selector(self.endEdit(_:)))
        self.addGestureRecognizer(endEdit)
        
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
    }
    
    func deleteAnnot() {
        self.removeFromSuperview()
    }
    
    func resizeBox(_ sender: UIPanGestureRecognizer) {
        self.annotBox.frame.size = CGSize(width: self.annotBox.frame.size.width + sender.translation(in: self).x, height: self.annotBox.frame.size.height + sender.translation(in: self).y)
        if self.annotBox.frame.origin.x > 0 {
            
        }
        if self.annotBox.frame.size.height < 65 {
            self.annotBox.frame = CGRect(x: self.annotBox.frame.origin.x, y: self.annotBox.frame.origin.y, width: self.annotBox.frame.size.width, height: 65)
        }
        if self.annotBox.frame.size.width < 150 {
            self.annotBox.frame = CGRect(x: self.annotBox.frame.origin.x, y: self.annotBox.frame.origin.y, width: 150, height: self.annotBox.frame.size.height)
        }
        sender.setTranslation(CGPoint.zero, in: self)
        layoutInstructionOverlay()
        layoutDeleteButton()
        layoutResizeHandle()
        self.setNeedsDisplay()
    }
    
    // MARK: AnnotBox Subview Layouts
    
    func layoutInstructionOverlay() {
        self.instructionOverlay.frame = self.annotBox.bounds
        self.instructionOverlay.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.tapToEditLabel.frame = CGRect(x: 30, y: 9, width: 120, height: 20)
        self.tapToEditLabel.text = "Tap to Edit"
        self.dragToMoveLabel.frame = CGRect(x: 30, y: self.annotBox.frame.size.height - 28, width: 120, height: 20)
        self.dragToMoveLabel.text = "Drag to Move"
        self.instructionOverlay.addSubview(tapToEditLabel)
        self.instructionOverlay.addSubview(dragToMoveLabel)
    }
    
    func layoutResizeHandle() {
        self.resizeHandle.frame = CGRect(x: 0, y: 0, width: 40, height:40)
        self.resizeHandle.backgroundColor = UIColor.white
        self.resizeHandle.layer.borderColor = UIColor.black.cgColor
        self.resizeHandle.layer.borderWidth = 1
        if annotBox.frame.origin.x > 0 {
            self.resizeHandle.center = CGPoint(x: self.annotBox.frame.origin.x + 4, y: self.annotBox.frame.origin.y + self.annotBox.frame.size.height - 4)
        } else {
            self.resizeHandle.center = CGPoint(x: self.annotBox.frame.size.width - boxOffset - 4, y: self.annotBox.frame.origin.y + self.annotBox.frame.size.height - 4)
        }
        let resizePan = UIPanGestureRecognizer(target: self, action: #selector(self.resizeBox(_:)))
        self.resizeHandle.addGestureRecognizer(resizePan)
        self.resizeHandle.isUserInteractionEnabled = true
    }
    
    func layoutDeleteButton() {
        self.deleteButton.frame = CGRect(x: 0, y: 0, width: 40, height:40)
        self.deleteButton.setTitle("X", for: .normal)
        self.deleteButton.backgroundColor = UIColor.red
        self.deleteButton.tintColor = UIColor.white
        self.deleteButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 24)
        self.deleteButton.titleLabel?.textColor = UIColor.white
        if annotBox.frame.origin.x > 0 {
            self.deleteButton.center = CGPoint(x: self.annotBox.frame.origin.x + 4, y: self.annotBox.frame.origin.y + 4)
        } else {
            self.deleteButton.center = CGPoint(x: self.annotBox.frame.size.width - boxOffset - 4, y: self.annotBox.frame.origin.y + 4)
        }
        self.deleteButton.layer.cornerRadius = 20
        self.deleteButton.addTarget(self, action: #selector(self.deleteAnnot), for: .touchUpInside)
    }
    
    func endEdit(_ sender: UITapGestureRecognizer) {
        self.deleteButton.removeFromSuperview()
        self.resizeHandle.removeFromSuperview()
        self.instructionOverlay.removeFromSuperview()
        self.editMode = false
        self.backgroundColor = UIColor.clear
        self.gestureRecognizers = []
    }
    
    // MARK: Coordinate Map Functions (used for Core Data storage)
    
    func mapToX(value: CGFloat) -> Float {
        return Float(value / self.pageSize.size.width)
    }

    func mapToY(value: CGFloat) -> Float {
        return Float(value / self.pageSize.size.height)
    }
    
    // MARK: Override Functions
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.editMode {
            return true
        }
        if self.annotBox.frame.contains(point) || self.annotDotContainer.frame.contains(point) || self.deleteButton.frame.contains(point) || self.resizeHandle.frame.contains(point) {
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
