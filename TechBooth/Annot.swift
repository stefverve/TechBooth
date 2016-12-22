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

protocol AnnotDelegate {
    func relabelAnnots()
}

class Annot: UIView {
    
    // MARK: Properties
    
    var annotDot = UIView()
    var annotBox = UIView(frame: CGRect.zero)
    var annotColor = UIColor()
    var annotDotContainer = UIView()
    var deleteButton = UIButton()
    var resizeHandle = UIView()
    var instructionOverlay = UIView()
    var tapToEditLabel = UILabel()
    var dragToMoveLabel = UILabel()
    var boxWidth = CGFloat()
    let boxOffset: CGFloat = 20
    var editMode: Bool = false
    var annot: Annotation? = nil
    var pageSize = CGRect.zero
    var annotType = AnnotType.light
    var pageNum = Int()
    var cueLabel = UILabel()
    var descriptionLabel = UILabel()
    var delegate: AnnotDelegate?
    
    // MARK: Inits
    
    init(pageNum: Int, dotLocation: CGPoint, rect: CGRect, type: AnnotType, allowEdits: Bool) {
        super.init(frame: rect)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.boxWidth = self.bounds.size.width * 0.2 + boxOffset
        self.pageSize = rect
        self.annotType = type
        self.pageNum = pageNum + 1
        
        self.colorFromEnum(type: type)
        
        self.createAnnotDot(dotLocation: dotLocation)
        
        // set up Annotation Box frame
        
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
        
        let boxRect = CGRect(x: x, y: y, width: self.boxWidth, height: 100)
        
        
        // Core Data
        self.annot = DataManager.share.makeAnnotation(page: pageNum + 1,
                                                      type: type.rawValue,
                                                      inRect: self.pageSize,
                                                      box: boxRect,
                                                      point: self.annotDotContainer.center)
        self.createAnnotBox(rect: boxRect)
        
        if allowEdits {
            self.setupGestures()
        }
        
        self.makeAnnotDesc()
    }
    
    func makeAnnotDesc() {
        self.annot?.cueDescription = "HAHAHAHAHAHAHA"
        DataManager.share.saveContext()
    }
    
    init(annotation: Annotation, rect: CGRect) {
        
        super.init(frame: rect)
        self.pageSize = rect
        self.annot = annotation
        self.annotType = AnnotType(rawValue: Int(annotation.type))!
        self.colorFromEnum(type: self.annotType)
        self.boxWidth = self.bounds.size.width * 0.2 + boxOffset
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.pageNum = Int(annotation.pageNumber)
        self.createAnnotDot(dotLocation: self.mapToPoint(x: annot!.dotX, y: annot!.dotY))
        self.createAnnotBox(rect: self.mapToRect(x: annot!.boxX, y: annot!.boxY, width: annot!.boxWidth, height: annot!.boxHeight))
        
        self.setupGestures()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: initializer convenience methods
    
    func colorFromEnum(type: AnnotType) {
        if type == AnnotType.light {
            self.annotColor = .blue
        } else if type == AnnotType.sound {
            self.annotColor = .orange
        } else {
            self.annotColor = .gray
        }
    }
    
    func createAnnotDot(dotLocation: CGPoint) {
        annotDotContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        annotDotContainer.backgroundColor = UIColor.clear
        annotDotContainer.center = dotLocation
        
        annotDot = UIView(frame: CGRect(x: 12.5, y: 12.5, width: 15, height: 15))
        annotDot.backgroundColor = self.annotColor.withAlphaComponent(1)
        annotDot.layer.cornerRadius = 7.5
        
        self.addSubview(annotDotContainer)
        annotDotContainer.addSubview(annotDot)
    }
    
    func createAnnotBox(rect: CGRect) {
        
        annotBox.frame = rect
        
        annotBox.backgroundColor = self.annotColor.withAlphaComponent(0.2)
        annotBox.layer.cornerRadius = 20
        annotBox.layer.borderColor = self.annotColor.withAlphaComponent(0.5).cgColor
        annotBox.layer.borderWidth = 4
        annotBox.clipsToBounds = true
        
        self.addSubview(annotBox)
        
        self.layoutAnnotBoxLabels()
        self.annotBox.addSubview(cueLabel)
        self.annotBox.addSubview(descriptionLabel)
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
  //      if sender.state == .ended {
            self.savePoint(point: self.annotDotContainer.center)
   //     }
        DataManager.share.reorderAllCues(page: self.pageNum, type: self.annotType.rawValue)
        delegate?.relabelAnnots()
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
        
        let editText = UITapGestureRecognizer(target: self, action: #selector(self.editText(_:)))
        self.instructionOverlay.addGestureRecognizer(editText)
        
        let moveBox = UITapGestureRecognizer(target: self, action: #selector(self.moveBox(_:)))
        self.instructionOverlay.addGestureRecognizer(moveBox)
        
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        
    }
    
    func deleteAnnot() {
        self.removeFromSuperview()
        DataManager.share.context().delete(self.annot!)
        DataManager.share.saveContext()
        DataManager.share.reorderAllCues(page: self.pageNum, type: self.annotType.rawValue)
        delegate?.relabelAnnots()
    }
    
    func resizeBox(_ sender: UIPanGestureRecognizer) {
        if self.annotBox.frame.origin.x > 0 {
            self.annotBox.frame = CGRect(x: self.annotBox.frame.origin.x + sender.translation(in: self).x, y: self.annotBox.frame.origin.y, width: self.annotBox.frame.size.width - sender.translation(in: self).x, height: self.annotBox.frame.size.height + sender.translation(in: self).y)
        } else {
            self.annotBox.frame = CGRect(x: self.annotBox.frame.origin.x, y: self.annotBox.frame.origin.y, width: self.annotBox.frame.size.width + sender.translation(in: self).x, height: self.annotBox.frame.size.height + sender.translation(in: self).y)
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
        layoutAnnotBoxLabels()
        self.setNeedsDisplay()
        if sender.state == .ended {
            self.saveFrame(frame: self.annotBox.frame)
        }
    }
    
    func moveBox(_ sender: UIPanGestureRecognizer) {
        if sender.location(in: self).x > self.frame.size.width/2 {
            self.annotBox.frame.origin = CGPoint(x: self.frame.size.width + self.boxOffset - self.annotBox.frame.size.width, y: sender.location(in: self).y - self.annotBox.frame.size.height/2)
        } else {
            self.annotBox.frame.origin = CGPoint(x: -self.boxOffset, y: sender.location(in: self).y - self.annotBox.frame.size.height/2)
        }
        layoutDeleteButton()
        layoutResizeHandle()
        layoutAnnotBoxLabels()
        self.setNeedsDisplay()
        if sender.state == .ended {
            self.saveFrame(frame: self.annotBox.frame)
        }
    }
    
    func editText(_ sender: UITapGestureRecognizer) {
      //  let typeDescriptionView = UIView(frame: self.frame)
        
    }
    
    func endEdit(_ sender: UITapGestureRecognizer) {
        self.deleteButton.removeFromSuperview()
        self.resizeHandle.removeFromSuperview()
        self.instructionOverlay.removeFromSuperview()
        self.editMode = false
        self.backgroundColor = UIColor.clear
        self.gestureRecognizers = []
    }
    
    // MARK: AnnotBox Subview Layouts
    
    func layoutAnnotBoxLabels() {
        let annotBoxLabelInset = CGFloat(8)
        
        if annotBox.frame.origin.x > 0 {
            cueLabel.frame = CGRect(x: annotBoxLabelInset, y: annotBoxLabelInset, width: annotBox.frame.size.width - annotBoxLabelInset*2 - boxOffset, height: 24)
            descriptionLabel.frame = CGRect(x: annotBoxLabelInset, y: annotBoxLabelInset*2 + 24, width: annotBox.frame.size.width - annotBoxLabelInset*2 - boxOffset, height: 24)
        } else {
            cueLabel.frame = CGRect(x: annotBoxLabelInset + boxOffset, y: annotBoxLabelInset, width: annotBox.frame.size.width - annotBoxLabelInset*2 - boxOffset, height: 24)
            descriptionLabel.frame = CGRect(x: annotBoxLabelInset + boxOffset, y: annotBoxLabelInset*2 + 24, width: annotBox.frame.size.width - annotBoxLabelInset*2 - boxOffset, height: 24)
        }
        cueLabel.text = String("\(self.pageNum).\(self.annot!.cueNum) - \(String(describing: self.annotType).capitalized)")
    }
    
    func layoutInstructionOverlay() {
        self.instructionOverlay.frame = self.annotBox.bounds
        self.instructionOverlay.backgroundColor = UIColor.gray
        self.tapToEditLabel.frame = CGRect(x: 30, y: 9, width: 120, height: 20)
        self.tapToEditLabel.text = "Tap to Edit"
        self.dragToMoveLabel.frame = CGRect(x: 30, y: self.annotBox.frame.size.height - 28, width: 120, height: 20)
        self.dragToMoveLabel.text = "Drag to Move"
        
        let movePan = UIPanGestureRecognizer(target: self, action: #selector(self.moveBox(_:)))
        self.instructionOverlay.addGestureRecognizer(movePan)
        
        let editTap = UITapGestureRecognizer(target: self, action: #selector(self.editText(_:)))
        self.instructionOverlay.addGestureRecognizer(editTap)
        
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
        self.deleteButton.layer.borderColor = UIColor.black.cgColor
        self.deleteButton.layer.borderWidth = 1
        self.deleteButton.addTarget(self, action: #selector(self.deleteAnnot), for: .touchUpInside)
    }
    
    
    
    // MARK: Coordinate Map Functions (used for Core Data storage)
    
    func saveFrame(frame: CGRect) {
        self.annot?.boxWidth = Float(frame.size.width / self.pageSize.size.width)
        self.annot?.boxHeight = Float(frame.size.height / self.pageSize.size.height)
        self.annot?.boxX = Float(frame.origin.x / self.pageSize.size.width)
        self.annot?.boxY = Float(frame.origin.y / self.pageSize.size.height)
        DataManager.share.saveContext()
    }
    
    func savePoint(point: CGPoint) {
        self.annot?.dotX = Float(point.x / self.pageSize.size.width)
        self.annot?.dotY = Float(point.y / self.pageSize.size.height)
        DataManager.share.saveContext()
    }
    
    func mapToRect(x: Float, y: Float, width: Float, height: Float) -> CGRect {
        return CGRect(x: CGFloat(x) * self.pageSize.size.width, y: CGFloat(y) * self.pageSize.size.height, width: CGFloat(width) * self.pageSize.size.width, height: CGFloat(height) * self.pageSize.size.height)
    }
    
    func mapToPoint(x: Float, y: Float) -> CGPoint {
        return CGPoint(x: CGFloat(x) * self.pageSize.size.width, y: CGFloat(y) * self.pageSize.size.height)
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
