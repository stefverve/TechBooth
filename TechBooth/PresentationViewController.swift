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
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var previousCueButton: UIButton!
    @IBOutlet weak var nextCueButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var annots = [Annot]()
    var annotIndex = 0
    var cueOverlayTop = UIView()
    var cueOverlayBottom = UIView()
    var client: UDPClient!
    
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
        
        goButton.layer.cornerRadius = goButton.frame.height/2
        goButton.layer.borderWidth = 4
        goButton.layer.borderColor = UIColor.green.cgColor
        
        let nextPath = UIBezierPath()
        nextPath.move(to: CGPoint(x: 0, y: 5))
        nextPath.addArc(withCenter: CGPoint(x: 5, y: 5) , radius: 5, startAngle: CGFloat(M_PI), endAngle: 3*CGFloat(M_PI_2), clockwise: true)
        nextPath.addLine(to: CGPoint(x: 60, y: 0))
        nextPath.addLine(to: CGPoint(x: 90, y: 30))
        nextPath.addLine(to: CGPoint(x: 60, y: 60))
        nextPath.addLine(to: CGPoint(x: 5, y: 60))
        nextPath.addArc(withCenter: CGPoint(x: 5, y: 55), radius: 5, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI), clockwise: true)
        let nextMask = CAShapeLayer()
        nextMask.path = nextPath.cgPath
        nextCueButton.layer.mask = nextMask
        
        let backPath = UIBezierPath()
        backPath.move(to: CGPoint(x: 90, y: 5))
        backPath.addLine(to: CGPoint(x: 90, y: 55))
        backPath.addArc(withCenter: CGPoint(x: 85, y: 55), radius: 5, startAngle: 0, endAngle: CGFloat(M_PI_2), clockwise: true)
        backPath.addLine(to: CGPoint(x: 30, y: 60))
        backPath.addLine(to: CGPoint(x: 0, y: 30))
        backPath.addLine(to: CGPoint(x: 30, y: 0))
        backPath.addLine(to: CGPoint(x: 85, y: 0))
        backPath.addArc(withCenter: CGPoint(x: 85, y: 5), radius: 5, startAngle: 3*CGFloat(M_PI_2), endAngle: 2*CGFloat(M_PI), clockwise: true)
        let backMask = CAShapeLayer()
        backMask.path = backPath.cgPath
        previousCueButton.layer.mask = backMask
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        scrollToCue()
        
        client = UDPClient(address: "192.168.2.39", port: 53535)
        
        let _ = client.send(string: "/workspace/2A8E5202-98F1-4A45-8AC7-0BC365522087/showMode 1")
        let _ = client.send(string: "/workspace/7AC16D43-DBEB-43AB-A0C2-6D2CA7989F1D/showMode 1")
        let _ = client.send(string: "/workspace/2A8E5202-98F1-4A45-8AC7-0BC365522087/select/1")
        let _ = client.send(string: "/workspace/7AC16D43-DBEB-43AB-A0C2-6D2CA7989F1D/select/1")
        
    }
    
    func layoutCueOverlay() {
        let locationInScroll = pdfScrollView.convert(annots[annotIndex].annotDotContainer.center, from: annots[annotIndex])
        
        cueOverlayTop.frame = CGRect(x: -20, y: 0, width: view.frame.width + 40, height: locationInScroll.y - 100)
        let topPath = CGMutablePath()
        topPath.addRect(cueOverlayTop.bounds)
        cueOverlayTop.layer.shadowPath = topPath
        
        cueOverlayBottom.frame = CGRect(x: -20, y: locationInScroll.y + 100, width: view.frame.width + 40, height: pdfScrollView.contentSize.height - locationInScroll.y - 100)
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
            
        } else {
            // redraw floating annotBox
            let dotRect = pdfScrollView.convert(annots[annotIndex].annotDotContainer.center, from: annots[annotIndex])
            rectToDisplay = CGRect(x: 0, y: dotRect.y - (view.frame.height/2), width: view.frame.width, height: view.frame.height)
        }
        
        pdfScrollView.scrollRectToVisible(rectToDisplay, animated: true)
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        
        if annots[annotIndex].annotType == .sound {
            let _ = client.send(string: "/workspace/2A8E5202-98F1-4A45-8AC7-0BC365522087/go")
        } else if annots[annotIndex].annotType == .light {
            let _ = client.send(string: "/workspace/7AC16D43-DBEB-43AB-A0C2-6D2CA7989F1D/go")
        }
        
        repeat {
        if annotIndex < annots.count - 1 {
            annotIndex += 1
        } else {
            print("no more cues")
            break
        }
        } while (annots[annotIndex].annotType == .note)
        
        
        
        
//        switch client.send(string: "/cue/next") {
//        case .success:
//            print("yay")
//        case .failure(let error):
//            print(error)
//        }
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
    
    @IBAction func previousCue(_ sender: UIButton) {
        
        repeat {
            if annotIndex > 0 {
                annotIndex -= 1
            } else {
                print("no more cues")
                break
            }
        } while (annots[annotIndex].annotType == .note)
        
        if annots[annotIndex].annotType == .sound {
            let _ = client.send(string: "/workspace/2A8E5202-98F1-4A45-8AC7-0BC365522087/select/previous")
        } else if annots[annotIndex].annotType == .light {
            let _ = client.send(string: "/workspace/7AC16D43-DBEB-43AB-A0C2-6D2CA7989F1D/select/previous")
        }
        
        layoutCueOverlay()
        scrollToCue()
        
    }
    
    @IBAction func skipCue(_ sender: UIButton) {
        
        repeat {
            if annotIndex < annots.count - 1 {
                annotIndex += 1
            } else {
                print("no more cues")
                break
            }
        } while (annots[annotIndex].annotType == .note)
        
        if annots[annotIndex].annotType == .sound {
            let _ = client.send(string: "/workspace/2A8E5202-98F1-4A45-8AC7-0BC365522087/select/next")
        } else if annots[annotIndex].annotType == .light {
            let _ = client.send(string: "/workspace/7AC16D43-DBEB-43AB-A0C2-6D2CA7989F1D/select/next")
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
