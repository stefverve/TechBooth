//
//  PDFPageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class PDFPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
 //   var orderedViewControllers: [SinglePageViewController]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // temp code to load pdf from bundle.main
        let document: CGPDFDocument = CGPDFDocument(Bundle.main.url(forResource: "Fyi", withExtension: "pdf")! as CFURL)!
        
        DataManager.share.document = document
        DataManager.share.pageCount = document.numberOfPages
        DataManager.share.pageSize = (document.page(at: 1)?.getBoxRect(CGPDFBox.mediaBox).size)!
        
//        for page in 1...self.pageCount {
//        
//        return [self.newColoredViewController(color: "Green"),
//                self.newColoredViewController(color: "Red"),
//                self.newColoredViewController(color: "Blue")]
//        }
        dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    
//    private(set) lazy var orderedViewControllers: [SinglePageViewController] = {
//        for page in 1...
//        
//        return [self.newColoredViewController("Green"),
//                self.newColoredViewController("Red"),
//                self.newColoredViewController("Blue")]
//    }()
    
    
    
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
