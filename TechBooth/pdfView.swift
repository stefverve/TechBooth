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
    
//    - (void)drawRect:(CGRect)rect
//    {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    // PDF might be transparent, assume white paper
//    [[UIColor whiteColor] set];
//    CGContextFillRect(ctx, rect);
//    
//    // Flip coordinates
//    CGContextGetCTM(ctx);
//    CGContextScaleCTM(ctx, 1, -1);
//    CGContextTranslateCTM(ctx, 0, -rect.size.height);
//    
//    // url is a file URL
//    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
//    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
//    
//    // get the rectangle of the cropped inside
//    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);
//    CGContextScaleCTM(ctx, rect.size.width / mediaRect.size.width,
//    rect.size.height / mediaRect.size.height);
//    CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y);
//    
//    // draw it
//    CGContextDrawPDFPage(ctx, page1);
//    CGPDFDocumentRelease(pdf);
//    }
//    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.fill(rect)
        
        ctx?.scaleBy(x: 1, y: -1)
        ctx?.translateBy(x: 0, y: -rect.size.height)
        
    //    let mediaRect = page.getBoxRect(CGPDFBox.mediaBox)
        
        ctx?.drawPDFPage(page)
        
        
    }
    

}
