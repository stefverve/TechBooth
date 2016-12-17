//
//  SinglePageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//


import UIKit
import CoreText

class SinglePageViewController: UIViewController {
    
    var page: CGPDFPage!
    var pageNum: Int!
    var pageViewRect: CGRect!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfScroller: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutForPDFSubview(size: pageViewRect.size)
    }
    
    func layoutForPDFSubview(size: CGSize) {
        self.pdfScroller.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if size.height < size.width {
            let pdfWidth = size.width
            let scalefactor = pdfWidth / DataManager.share.pageRect.size.width
            self.pdfView.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: DataManager.share.pageRect.size.height * scalefactor)
        } else {
            self.pdfView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        self.pdfScroller.contentSize = self.pdfView.frame.size
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.layoutForPDFSubview(size: size)
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)

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
