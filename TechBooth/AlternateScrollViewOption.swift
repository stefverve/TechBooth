//
//  AlternateScrollViewOption.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class AlternateScrollViewOption: UIViewController {
    
    @IBOutlet weak var pdfScrollView: UIScrollView!
    var scrollOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //     self.pdfScrollView.backgroundColor = UIColor.black
        let document: CGPDFDocument = CGPDFDocument(Bundle.main.url(forResource: "Fyi", withExtension: "pdf")! as CFURL)!
        
        DataManager.share.document = document
        DataManager.share.pageCount = document.numberOfPages
        DataManager.share.pageRect = (document.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
        
        self.drawScroller()
        
        // Do any additional setup after loading the view.
    }
    
    func drawScroller() {
        let scaleFactor = self.view.frame.size.width/DataManager.share.pageRect.size.width
        
        self.pdfScrollView.contentSize = CGSize(width: self.pdfScrollView.frame.size.width, height: (CGFloat)(DataManager.share.pageCount) * (DataManager.share.pageRect.size.height * scaleFactor))
        
        for page in 1...DataManager.share.pageCount {
            let newPage = pdfView(frame: CGRect(x: 0, y: CGFloat(page-1)*DataManager.share.pageRect.size.height*scaleFactor, width: DataManager.share.pageRect.size.width*scaleFactor, height: DataManager.share.pageRect.size.height*scaleFactor))
            newPage.page = DataManager.share.document.page(at: page)
            //    newPage.frame = CGRect(x: 0, y: CGFloat(page-1)*DataManager.share.pageRect.size.height*scaleFactor, width: DataManager.share.pageRect.size.width*scaleFactor, height: DataManager.share.pageRect.size.height*scaleFactor)
            self.pdfScrollView.addSubview(newPage)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.scrollOffset = self.pdfScrollView.contentOffset.y/(self.pdfScrollView.contentSize.height - self.pdfScrollView.frame.size.height)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.pdfScrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.drawScroller()
        self.pdfScrollView.setContentOffset(CGPoint(x: 0, y: self.scrollOffset * (self.pdfScrollView.contentSize.height - self.pdfScrollView.frame.size.height)), animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
