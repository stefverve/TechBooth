//
//  PresentationViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class PresentationViewController: UIViewController {

    @IBOutlet weak var pdfScrollView: UIScrollView!
    @IBOutlet weak var dock: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    var annots = [Annot]()
    var annotIndex = 0
    var cueOverlayTop = UIView()
    var cueOverlayBottom = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageRect = view.bounds
  //      let pdfPageSize = DataManager.share.document.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox)
  //      let scaleFactor = pageRect.width / (pdfPageSize?.width)!
        
        pdfScrollView.contentSize = CGSize(width: pageRect.width, height: ((pageRect.height + 5) * CGFloat(DataManager.share.document.numberOfPages)) - 5)
        pdfScrollView.backgroundColor = UIColor.darkGray
        
        for page in 1...DataManager.share.document.numberOfPages {
            
            let pdfView = PDFView(frame: CGRect(x: 0, y: (pageRect.height + 5) * CGFloat(page - 1), width: pageRect.width, height: pageRect.height))
            pdfView.page = DataManager.share.document.page(at: page)
            
            for annotation in DataManager.share.fetchPageAnnotations(page: page) {
                let annot = Annot.init(annotation: annotation, rect: pdfView.bounds, allowEdits: false)
                annots.append(annot)
                pdfView.addSubview(annot)
            }
            
            annotIndex = annots.count - 1
            
            pdfScrollView.addSubview(pdfView)
            
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        annotIndex = 0
        
        cueOverlayBottom.layer.shadowOpacity = 0.2
        cueOverlayBottom.layer.shadowRadius = 10
        
        cueOverlayTop.layer.shadowOpacity = 0.2
        cueOverlayTop.layer.shadowRadius = 10
        
        pdfScrollView.addSubview(cueOverlayTop)
        pdfScrollView.addSubview(cueOverlayBottom)
        layoutCueOverlay()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        scrollToCue()
    }
    
    func layoutCueOverlay() {
        let locationInScroll = pdfScrollView.convert(annots[annotIndex].annotDotContainer.center, from: annots[annotIndex])
        
        cueOverlayTop.frame = CGRect(x: -20, y: 0, width: view.frame.width + 20, height: locationInScroll.y - 100)
        let topPath = CGMutablePath()
        topPath.addRect(cueOverlayTop.bounds)
        cueOverlayTop.layer.shadowPath = topPath
        
        cueOverlayBottom.frame = CGRect(x: -20, y: locationInScroll.y + 100, width: view.frame.width + 20, height: pdfScrollView.contentSize.height - locationInScroll.y - 100)
        let bottomPath = CGMutablePath()
        bottomPath.addRect(cueOverlayBottom.bounds)
        cueOverlayBottom.layer.shadowPath = bottomPath
        
        
    }
    
    func scrollToCue() {
        var rectToDisplay = pdfScrollView.convert(annots[annotIndex].annotBox.frame.union(annots[annotIndex].annotDotContainer.frame), from: annots[annotIndex])
        
        if rectToDisplay.height <= view.frame.height - dock.frame.height - 100 {
            let newRectHeight = rectToDisplay.height + dock.frame.height + 100
            let diff = (view.frame.height - newRectHeight) / 2
            rectToDisplay = CGRect(x: rectToDisplay.origin.x, y: rectToDisplay.origin.y - diff, width: rectToDisplay.size.width, height: newRectHeight + (diff * 2))
            
           // rectToDisplay = CGRect(x: rectToDisplay.origin.x, y: rectToDisplay.origin.y, width: rectToDisplay.size.width, height: rectToDisplay.size.height + dock.frame.height + 70)
        } else {
            // redraw floating annotBox
            let dotRect = pdfScrollView.convert(annots[annotIndex].annotDotContainer.center, from: annots[annotIndex])
            rectToDisplay = CGRect(x: 0, y: dotRect.y - (view.frame.height/2), width: view.frame.width, height: view.frame.height)
        }
        
        pdfScrollView.scrollRectToVisible(rectToDisplay, animated: true)
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        if annotIndex < annots.count - 1 {
            annotIndex += 1
        } else {
            print("no more cues")
        }
        layoutCueOverlay()
        scrollToCue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismissPresentationView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
