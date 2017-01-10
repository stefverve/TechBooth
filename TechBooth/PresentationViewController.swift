//
//  PresentationViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit
import SwiftSocket

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
        
        
        
        let client = UDPClient(address: "192.168.1.112", port: 53535)
        
        switch client.send(string: "/cue/selected/start") {
        case .success:
            print("yay")
        case .failure(let error):
            print(error)
        }
        
//        UDP is messy, but it works.  Rather use TCP, but that requires port 53000,
//        and OSC 1.1 spec, the formatting for which appears to be hosted at
//        http://cnmat.berkeley.edu/publication/features_and_future_open_sound_control_version_1_1_nime
//        site is down, if it ever comes back up, revisit this code!!
//
//        let client = TCPClient(address: "192.168.1.112", port: 53000)
//        switch client.connect(timeout: 1) {
//        case .success:
//            switch client.send(string: "GO" ) {
//            case .success:
//                                guard let data = client.read(1024*10) else { return }
//                
//                                if let response = String(bytes: data, encoding: .utf8) {
//                                    print(response)
//                                }
//                print("yay")
//            case .failure(let error):
//                print(error)
//            }
//        case .failure(let error):
//            print(error)
//        }
        
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
