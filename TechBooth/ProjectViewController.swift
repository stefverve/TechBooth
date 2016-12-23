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
    
    var lightCueButtonBottom: NSLayoutConstraint!
    var lightCueButtonTop: NSLayoutConstraint!
    var lightCueButtonCenterY: NSLayoutConstraint!
    
    var soundCueButtonBottom: NSLayoutConstraint!
    var soundCueButtonTop: NSLayoutConstraint!
    var soundCueButtonCenterY: NSLayoutConstraint!
    
    var textCueButtonBottom: NSLayoutConstraint!
    var textCueButtonTop: NSLayoutConstraint!
    
    var menuWidth: CGFloat!
    var expandedMenu = false
    var annotType: AnnotType = .light
    
    
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
        
        lightCueButton.addTarget(self, action: #selector(self.toggleLightButton), for: .touchUpInside)
        soundCueButton.addTarget(self, action: #selector(self.toggleSoundButton), for: .touchUpInside)
        textCueButton.addTarget(self, action: #selector(self.toggleTextButton), for: .touchUpInside)
        
        
        
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
        
        shadowHeightConstraint = cueMenuShadowLayer.heightAnchor.constraint(equalToConstant: menuWidth)
        shadowHeightConstraint.isActive = true
        cueMenuShadowLayer.widthAnchor.constraint(equalToConstant: menuWidth).isActive = true
        cueMenuShadowLayer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        cueMenuShadowLayer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        cueMenuShapeLayer.heightAnchor.constraint(equalTo: cueMenuShadowLayer.heightAnchor, multiplier: 1).isActive = true
        cueMenuShapeLayer.widthAnchor.constraint(equalTo: cueMenuShadowLayer.widthAnchor, multiplier: 1).isActive = true
        cueMenuShapeLayer.centerXAnchor.constraint(equalTo: cueMenuShadowLayer.centerXAnchor).isActive = true
        cueMenuShapeLayer.centerYAnchor.constraint(equalTo: cueMenuShadowLayer.centerYAnchor).isActive = true
        
        lightCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        soundCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        textCueButton.heightAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        lightCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        soundCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        textCueButton.centerXAnchor.constraint(equalTo: cueMenuShapeLayer.centerXAnchor).isActive = true
        
        lightCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        soundCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        textCueButton.widthAnchor.constraint(equalTo: cueMenuShapeLayer.widthAnchor).isActive = true
        
        lightCueButtonBottom = lightCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0)
        lightCueButtonBottom.isActive=true
        lightCueButtonTop = lightCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0)
        lightCueButtonTop.isActive=false
        lightCueButtonCenterY = lightCueButton.centerYAnchor.constraint(equalTo: cueMenuShapeLayer.centerYAnchor, constant: 0)
        lightCueButtonCenterY.isActive=false
        
        soundCueButtonBottom = soundCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0)
            soundCueButtonBottom.isActive=false
        soundCueButtonTop = soundCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0)
            soundCueButtonTop.isActive=false
        soundCueButtonCenterY = soundCueButton.centerYAnchor.constraint(equalTo: cueMenuShapeLayer.centerYAnchor, constant: 0)
        soundCueButtonCenterY.isActive=true
        
        textCueButtonBottom = textCueButton.bottomAnchor.constraint(equalTo: cueMenuShapeLayer.bottomAnchor, constant: 0)
            textCueButtonBottom.isActive=false
        textCueButtonTop = textCueButton.topAnchor.constraint(equalTo: cueMenuShapeLayer.topAnchor, constant: 0)
            textCueButtonTop.isActive=true
        
        lightCueButton.backgroundColor = UIColor.blue
        soundCueButton.backgroundColor = UIColor.orange
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

    func toggleLightButton() {
        lightCueButton.isSelected = true
        soundCueButton.isSelected = false
        textCueButton.isSelected = false
        if expandedMenu {
            
            annotType = .light
            
            cueMenuShapeLayer.bringSubview(toFront: soundCueButton)
            cueMenuShapeLayer.bringSubview(toFront: lightCueButton)
            
            hideCueMenu()
            
            
        } else {
            showCueMenu()
        }
    }
    
    func toggleSoundButton() {
        lightCueButton.isSelected = false
        soundCueButton.isSelected = true
        textCueButton.isSelected = false
        if expandedMenu {
            
            annotType = .sound
            
            cueMenuShapeLayer.bringSubview(toFront: lightCueButton)
            cueMenuShapeLayer.bringSubview(toFront: soundCueButton)
            
            hideCueMenu()
            
            
        } else {
            showCueMenu()
        }
    }
    
    func toggleTextButton() {
        lightCueButton.isSelected = false
        soundCueButton.isSelected = false
        textCueButton.isSelected = true
        if expandedMenu {
            
            annotType = .note
            
            cueMenuShapeLayer.bringSubview(toFront: soundCueButton)
            cueMenuShapeLayer.bringSubview(toFront: textCueButton)
            
            hideCueMenu()
            
            
        } else {
            showCueMenu()
        }
    }
    
    func showCueMenu() {
        expandedMenu = true
        UIView.animate(withDuration: 0.4, animations: {
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
    
    func hideCueMenu() {
        expandedMenu = false
        UIView.animate(withDuration: 0.4, animations: {
            self.shadowHeightConstraint.constant = self.menuWidth
            let maskRect = CGRect(x: 0, y: 0, width: self.cueMenuShadowLayer.frame.width, height: self.menuWidth)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.cueMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            
            if self.lightCueButton.isSelected {
                self.lightCueButtonBottom.isActive=true
                self.lightCueButtonTop.isActive=false
                self.lightCueButtonCenterY.isActive=false
                
                self.soundCueButtonBottom.isActive=false
                self.soundCueButtonTop.isActive=false
                self.soundCueButtonCenterY.isActive=true
                
                self.textCueButtonBottom.isActive=false
                self.textCueButtonTop.isActive=true
                
            } else if self.soundCueButton.isSelected {
                self.lightCueButtonBottom.isActive=false
                self.lightCueButtonTop.isActive=false
                self.lightCueButtonCenterY.isActive=true
                
                self.soundCueButtonBottom.isActive=true
                self.soundCueButtonTop.isActive=false
                self.soundCueButtonCenterY.isActive=false
                
                self.textCueButtonBottom.isActive=false
                self.textCueButtonTop.isActive=true
                
            } else {
                self.lightCueButtonBottom.isActive=false
                self.lightCueButtonTop.isActive=true
                self.lightCueButtonCenterY.isActive=false
                
                self.soundCueButtonBottom.isActive=false
                self.soundCueButtonTop.isActive=false
                self.soundCueButtonCenterY.isActive=true
                
                self.textCueButtonBottom.isActive=true
                self.textCueButtonTop.isActive=false
                
            }
            
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
