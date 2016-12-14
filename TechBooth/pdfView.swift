//
//  pdfView.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class pdfView: UIView {

    var page: CGPDFPage!
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.fill(rect)
        let mediaRect = page.getBoxRect(CGPDFBox.mediaBox)
        ctx?.scaleBy(x: rect.size.width/mediaRect.size.width, y: -rect.size.height/mediaRect.size.height)
        ctx?.translateBy(x: 0, y: -mediaRect.size.height)
    
        ctx?.drawPDFPage(page)
        
    }
    

}
