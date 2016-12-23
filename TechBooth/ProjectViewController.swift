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
    var lightCueButton = UIButton()
    var soundCueButton = UIButton()
    var textCueButton = UIButton()
    var cueMenuShadowLayer = UIView()
    var cueMenuShapeLayer = UIView()
    var shadowHeightConstraint: NSLayoutConstraint!
    var menuWidth: CGFloat!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        menuWidth = self.view.frame.size.width * 0.12
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
        
      //  let menuWidth: CGFloat = self.view.frame.size.width * 0.12
        
        cueMenuShadowLayer.frame = CGRect(x: self.view.frame.size.width - menuWidth, y: self.view.frame.size.height - menuWidth, width: menuWidth, height: menuWidth)
        cueMenuShadowLayer.layer.shadowRadius = 3
        cueMenuShadowLayer.layer.shadowColor = UIColor.black.cgColor
        cueMenuShadowLayer.layer.shadowOpacity = 0.8
        cueMenuShadowLayer.layer.shadowOffset = CGSize.zero
        
        cueMenuShapeLayer.frame = cueMenuShadowLayer.bounds
        var path = UIBezierPath(roundedRect: cueMenuShapeLayer.bounds, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: menuWidth/10, height: menuWidth/10))
        var mask = CAShapeLayer()
        mask.path = path.cgPath
        cueMenuShapeLayer.layer.mask = mask
        cueMenuShapeLayer.backgroundColor = UIColor(white: 0.85, alpha: 1)
        
        
        lightCueButton.addTarget(self, action: #selector(self.showCueMenu), for: .touchUpInside)
        
        cueMenuShadowLayer.translatesAutoresizingMaskIntoConstraints = false
        cueMenuShapeLayer.translatesAutoresizingMaskIntoConstraints = false
        lightCueButton.translatesAutoresizingMaskIntoConstraints = false
        soundCueButton.translatesAutoresizingMaskIntoConstraints = false
        textCueButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.view.addSubview(cueMenuShadowLayer)
        cueMenuShadowLayer.addSubview(cueMenuShapeLayer)
        
        
        cueMenuShapeLayer.addSubview(textCueButton)
        cueMenuShapeLayer.addSubview(soundCueButton)
        cueMenuShapeLayer.addSubview(lightCueButton)
        
        lightCueButton.frame = cueMenuShapeLayer.bounds
        soundCueButton.frame = cueMenuShapeLayer.bounds
        textCueButton.frame = cueMenuShapeLayer.bounds
        
   //     let shadowMargins = cueMenuShadowLayer.layoutMarginsGuide
        
        shadowHeightConstraint = cueMenuShadowLayer.heightAnchor.constraint(equalToConstant: menuWidth)
        shadowHeightConstraint.isActive = true
        cueMenuShadowLayer.widthAnchor.constraint(equalToConstant: menuWidth).isActive = true
        cueMenuShadowLayer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        cueMenuShadowLayer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        cueMenuShapeLayer.heightAnchor.constraint(equalTo: cueMenuShadowLayer.heightAnchor, multiplier: 1).isActive = true
        cueMenuShapeLayer.widthAnchor.constraint(equalTo: cueMenuShadowLayer.widthAnchor, multiplier: 1).isActive = true
        cueMenuShapeLayer.centerXAnchor.constraint(equalTo: cueMenuShadowLayer.centerXAnchor).isActive = true
        cueMenuShapeLayer.centerYAnchor.constraint(equalTo: cueMenuShadowLayer.centerYAnchor).isActive = true
        
   //     let cueMenuShapeLayer = cueMenuShapeLayer.layoutMarginsGuide
        
        lightCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        soundCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        textCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        lightCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        soundCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        textCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        
        lightCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        soundCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        textCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        
        lightCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0).isActive=true
        lightCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0).isActive=false
        lightCueButton.centerYAnchor.constraint(equalTo: cueMenuShapeLayer.centerYAnchor, constant: 0).isActive=false
        lightCueButton.backgroundColor = UIColor.blue
        
        soundCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0).isActive=false
        soundCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0).isActive=false
        soundCueButton.centerYAnchor.constraint(equalTo: cueMenuShapeLayer.centerYAnchor, constant: 0).isActive=true
        soundCueButton.backgroundColor = UIColor.orange
        
        textCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0).isActive=false
        textCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0).isActive=true
        textCueButton.centerYAnchor.constraint(equalTo: cueMenuShapeLayer.centerYAnchor, constant: 0).isActive=false
        textCueButton.backgroundColor = UIColor.brown
        
        
        
        
        let settingsMenuBackingLayer = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height - menuWidth, width: menuWidth, height: menuWidth))
        let settingsMenu = UIButton(frame: settingsMenuBackingLayer.bounds)
        settingsMenu.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        path = UIBezierPath(roundedRect: settingsMenu.bounds, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: menuWidth/10, height: menuWidth/10))
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

    }
    
    func layoutIPad(rect: CGRect) {
        self.pageViewController!.view.frame = rect//.insetBy(dx: 20, dy: 20)  // FIX THIS
    }

    
    func showCueMenu() {
        print("show cue menu here")
        UIView.animate(withDuration: 0.4, animations: {
           // let stretch: CGFloat = self.view.frame.size.width * 0.24
            let newHeight = self.menuWidth * 3
            self.shadowHeightConstraint.constant = newHeight
            let maskRect = CGRect(x: 0, y: 0, width: self.cueMenuShadowLayer.frame.width, height: newHeight)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.cueMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        })
    }
    
    func showSettingsMenu() {
        print ("show settings menu here")
        self.dismiss(animated: true, completion: nil)
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
