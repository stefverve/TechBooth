//
//  SinglePageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit
import CoreText

class SinglePageViewController: UIViewController {
    
    var page: CGPDFPage!
    var pageNum: Int!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfScroller: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {
            let pdfWidth = self.view.frame.width
            let scalefactor = pdfWidth / DataManager.share.pageRect.size.width
            self.pdfView.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: DataManager.share.pageRect.size.height * scalefactor)
        } else {
            self.pdfView.frame = self.view.frame
        }
        self.pdfScroller.contentSize = self.pdfView.frame.size
        
 //       let label = UILabel(frame: CGRect(x: 10, y: 10, width: 300, height: 44))
  //      label.text = "Page \(pageNum)"
 //       view.addSubview(label)
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
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
