//
//  SinglePageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//


import UIKit
import CoreText



class SinglePageViewController: UIViewController, AnnotDelegate {
    
    var page: CGPDFPage!
    var pageNum: Int!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfScroller: UIScrollView!
    var annotType: AnnotType!
    var annots = [Annot]()
    
    var allowEdits: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)
        self.annotType = .light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutForPDFSubview(size: self.view.frame.size)
        if annots.count == 0 {
            for annotation in DataManager.share.fetchPageAnnotations(page: pageNum + 1) {
                let annot = Annot.init(annotation: annotation, rect: pdfView.frame, allowEdits: allowEdits)
                self.annots.append(annot)
                pdfView.addSubview(annot)
                annot.delegate = self
            }
        }
    }
    
    // method commented out -- pages loaded off-screen are loaded at default frame size, and need to be re-adjusted if they are to be stretched to a different frame. This should ideally be fixed, but is not relevant at the moment since we are only dispalying the PDF full screen.
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if self.pdfView.frame.size.width > self.view.frame.size.width {
//            layoutForPDFSubview(size: self.view.frame.size)
//        }
//    }
    
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
        self.layoutForPDFSubview(size: CGSize(width: self.view.frame.size.height, height: self.view.frame.size.width))
        self.pdfView.page = DataManager.share.document.page(at: pageNum+1)

    }
    
    @IBAction func didTapPage(_ sender: UITapGestureRecognizer) {
        print (sender.location(in: pdfView))
        let annot = Annot.init(pageNum: self.pageNum, dotLocation: sender.location(in: pdfView), rect: pdfView.frame, type: self.annotType, allowEdits: allowEdits)
        annot.delegate = self
        
        pdfView.addSubview(annot)
        print(self.pdfView.subviews.count)
        self.annots.append(annot)
        relabelAnnots()
    }
    
    func relabelAnnots() {
        for annot in annots {
            annot.layoutAnnotBoxLabels()
        }
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
