//
//  PDFPageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class ProjectViewController: UIViewController {
    
    var pageViewController: UIPageViewController?
    
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // temp code to load pdf from bundle.main
        let document: CGPDFDocument = CGPDFDocument(Bundle.main.url(forResource: "Fyi", withExtension: "pdf")! as CFURL)!
        
        DataManager.share.document = document
        DataManager.share.pageCount = document.numberOfPages
        DataManager.share.pageRect = (document.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox))!
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        
        let startingViewController: SinglePageViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)
        
    }
    
    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }
    
    var _modelController: ModelController? = nil

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    private func newColoredViewController(color: String) -> SinglePageViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "pdfPage") as! SinglePageViewController
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
