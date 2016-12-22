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
    var editMenu: EditMenu?
    
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.lightGray
		
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.layoutDevice(rect: self.view.bounds)
        self.modelController.pageViewRect = self.pageViewController?.view.bounds
        let startingViewController: SinglePageViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        startingViewController.view.frame = (self.pageViewController?.view.bounds)!
        
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        self.pageViewController!.didMove(toParentViewController: self)
        
        let menuWidth: CGFloat = self.view.frame.size.width * 0.12
        
        let cueMenuBackingLayer = UIView(frame: CGRect(x: self.view.frame.size.width - menuWidth, y: self.view.frame.size.height - menuWidth, width: menuWidth, height: menuWidth))
        let cueMenu = UIButton(frame: cueMenuBackingLayer.bounds)
        cueMenu.addTarget(self, action: #selector(self.showCueMenu), for: .touchUpInside)
        var path = UIBezierPath(roundedRect: cueMenu.bounds, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: menuWidth/12, height: menuWidth/12))
        var mask = CAShapeLayer()
        mask.path = path.cgPath
        cueMenu.layer.mask = mask
        cueMenu.backgroundColor = UIColor(white: 0.85, alpha: 1)
        cueMenuBackingLayer.layer.shadowRadius = 3
        cueMenuBackingLayer.layer.shadowColor = UIColor.black.cgColor
        cueMenuBackingLayer.layer.shadowOpacity = 0.8
        cueMenuBackingLayer.layer.shadowOffset = CGSize.zero
        cueMenuBackingLayer.addSubview(cueMenu)
        self.view.addSubview(cueMenuBackingLayer)
        
        let settingsMenuBackingLayer = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height - menuWidth, width: menuWidth, height: menuWidth))
        let settingsMenu = UIButton(frame: settingsMenuBackingLayer.bounds)
        settingsMenu.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        path = UIBezierPath(roundedRect: settingsMenu.bounds, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: menuWidth/12, height: menuWidth/12))
        mask = CAShapeLayer()
        mask.path = path.cgPath
        settingsMenu.layer.mask = mask
        settingsMenu.backgroundColor = UIColor(white: 0.85, alpha: 1)
        settingsMenuBackingLayer.layer.shadowRadius = 3
        settingsMenuBackingLayer.layer.shadowColor = UIColor.black.cgColor
        settingsMenuBackingLayer.layer.shadowOpacity = 0.8
        settingsMenuBackingLayer.layer.shadowOffset = CGSize.zero
        settingsMenuBackingLayer.addSubview(settingsMenu)
        self.view.addSubview(settingsMenuBackingLayer)
        
    }
    
    func layoutDevice(rect: CGRect) {
  //      if UIDevice.current.userInterfaceIdiom == .pad {
            self.layoutIPad(rect: rect)
//        } else {
//            if self.editMenu == nil {
//                self.editMenu = EditMenu.fromXib()
//                self.view.addSubview(self.editMenu!)
//            }
//            if self.traitCollection.verticalSizeClass == .compact {
//                layoutLandscapeIPhone(rect: rect)
//            } else if self.traitCollection.horizontalSizeClass == .compact {
//                layoutPortraitIPhone(rect: rect)
//            }
//        }
    }
    
    func layoutIPad(rect: CGRect) {
        self.pageViewController!.view.frame = rect//.insetBy(dx: 20, dy: 20)  // FIX THIS
    }
    
    func layoutLandscapeIPhone(rect: CGRect) {
        self.pageViewController!.view.frame = CGRect(x: 0, y: 0, width: rect.size.width - (rect.size.height/4), height: rect.size.height)
        self.editMenu?.frame = CGRect(x: rect.size.width - rect.size.height/4, y: 0, width: rect.size.height/4, height: rect.size.height)
    }
    
    func layoutPortraitIPhone(rect: CGRect) {
        self.pageViewController!.view.frame = CGRect(x: 0, y: rect.size.width/4, width: rect.size.width, height: rect.size.height - rect.size.width/4)
        self.editMenu?.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.width/4)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        let rect = CGRect(origin: CGPoint.zero, size: size)
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            layoutIPad(rect: rect)
//        } else if size.width > size.height {
//            layoutLandscapeIPhone(rect: rect)
//        } else if size.height > size.width {
//            layoutPortraitIPhone(rect: rect)
//        }
//    }
    
    func showCueMenu() {
        print("show cue menu here")
    }
    
    func showSettingsMenu() {
        print ("show settings menu here")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
