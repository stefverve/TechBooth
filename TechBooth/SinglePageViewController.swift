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
     //   layoutForPDFSubview(size: self.view.frame.size)
        
self.pdfView.page = DataManager.share.document.page(at: pageNum+1)
        layoutForPDFSubview(size: self.view.frame.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func layoutForPDFSubview(size: CGSize) {
        self.pdfScroller.frame = self.view.frame
        if size.height < size.width {
            let pdfWidth = size.width
            let scalefactor = pdfWidth / DataManager.share.pageRect.size.width
            self.pdfView.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: DataManager.share.pageRect.size.height * scalefactor)
        } else {
            self.pdfView.frame = self.view.frame
        }
        /*       if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {
            let pdfWidth = self.view.frame.width
            let scalefactor = pdfWidth / DataManager.share.pageRect.size.width
            self.pdfView.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: DataManager.share.pageRect.size.height * scalefactor)
        } else {
            self.pdfView.frame = self.view.frame
        } */
        self.pdfScroller.contentSize = self.pdfView.frame.size
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.layoutForPDFSubview(size: size)
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)

        
    }
/*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // self.layoutForPDFSubview(size: self.view.frame.size)
    }
    
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
