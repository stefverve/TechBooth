//
//  PDFPageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class ProjectViewController: UIViewController, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    var lightCueButton = UIButton()
    var soundCueButton = UIButton()
    var textCueButton = UIButton()
    var cueMenuShadowLayer = UIView()
    var cueMenuShapeLayer = UIView()
    var cueMenuShadowHeightConstraint: NSLayoutConstraint!
    
    var lightCueButtonBottom: NSLayoutConstraint!
    var lightCueButtonTop: NSLayoutConstraint!
    var lightCueButtonCenterY: NSLayoutConstraint!
    
    var soundCueButtonBottom: NSLayoutConstraint!
    var soundCueButtonTop: NSLayoutConstraint!
    var soundCueButtonCenterY: NSLayoutConstraint!
    
    var textCueButtonBottom: NSLayoutConstraint!
    var textCueButtonTop: NSLayoutConstraint!
    
    var settingsMenuShadowLayer = UIView()
    var settingsMenuShapeLayer = UIView()
    var settingsMenuShadowHeightConstraint: NSLayoutConstraint!
    
    var mainMenuButton = UIButton()
    var lightTableButton = UIButton()
    var soundTableButton = UIButton()
    
    var menuWidth: CGFloat!
    var expandedMenu = false
    var annotType: AnnotType = .light
    
    var currentPage: SinglePageViewController!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        menuWidth = self.view.frame.size.width * 0.12
		
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController?.delegate = self
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
        
        lightCueButton.setImage(UIImage(named: "Light"), for: .normal)
        soundCueButton.setImage(UIImage(named: "Speakers"), for: .normal)
        textCueButton.setImage(UIImage(named: "Notes"), for: .normal)
        
        cueMenuShadowHeightConstraint = cueMenuShadowLayer.heightAnchor.constraint(equalToConstant: menuWidth)
        cueMenuShadowHeightConstraint.isActive = true
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
        
        self.view.addSubview(settingsMenuShadowLayer)
        settingsMenuShadowLayer.addSubview(settingsMenuShapeLayer)
        
        settingsMenuShadowHeightConstraint = settingsMenuShadowLayer.heightAnchor.constraint(equalToConstant: menuWidth)
        settingsMenuShadowHeightConstraint.isActive = true
        settingsMenuShadowLayer.widthAnchor.constraint(equalToConstant: menuWidth).isActive = true
        settingsMenuShadowLayer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        settingsMenuShadowLayer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        
        //settingsMenuShadowLayer.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height - menuWidth, width: menuWidth, height: menuWidth)
        settingsMenuShadowLayer.layer.shadowRadius = 3
        settingsMenuShadowLayer.layer.shadowColor = UIColor.black.cgColor
        settingsMenuShadowLayer.layer.shadowOpacity = 0.8
        settingsMenuShadowLayer.layer.shadowOffset = CGSize.zero
        
        //settingsMenuShapeLayer.frame = settingsMenuShadowLayer.bounds
        
        settingsMenuShapeLayer.bottomAnchor.constraint(equalTo: settingsMenuShadowLayer.bottomAnchor).isActive = true
        settingsMenuShapeLayer.trailingAnchor.constraint(equalTo: settingsMenuShadowLayer.trailingAnchor).isActive = true
        settingsMenuShapeLayer.widthAnchor.constraint(equalTo: settingsMenuShadowLayer.widthAnchor).isActive = true
        settingsMenuShapeLayer.heightAnchor.constraint(equalTo: settingsMenuShadowLayer.heightAnchor).isActive = true
        
//        let settingsPath = UIBezierPath(roundedRect: settingsMenuShapeLayer.bounds, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: menuWidth/10, height: menuWidth/10))
//        let settingsMask = CAShapeLayer()
//        settingsMask.path = settingsPath.cgPath
//        settingsMenuShapeLayer.layer.mask = settingsMask
        
        path = UIBezierPath(roundedRect: cueMenuShapeLayer.bounds, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: menuWidth/10, height: menuWidth/10))
        mask = CAShapeLayer()
        mask.path = path.cgPath
        settingsMenuShapeLayer.layer.mask = mask
//        
        settingsMenuShapeLayer.backgroundColor = UIColor(white: 0.85, alpha: 1)
        
        mainMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        
        mainMenuButton.backgroundColor = UIColor.red
        
        settingsMenuShadowLayer.translatesAutoresizingMaskIntoConstraints = false
        settingsMenuShapeLayer.translatesAutoresizingMaskIntoConstraints = false
        mainMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingsMenuShapeLayer.addSubview(mainMenuButton)
        
        mainMenuButton.centerXAnchor.constraint(equalTo: settingsMenuShapeLayer.centerXAnchor).isActive = true
        mainMenuButton.widthAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor).isActive = true
        mainMenuButton.bottomAnchor.constraint(equalTo: settingsMenuShapeLayer.bottomAnchor).isActive = true
        mainMenuButton.heightAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        mainMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        
        mainMenuButton.backgroundColor = UIColor.red
        
        
        currentPage = (self.pageViewController?.viewControllers?.first)! as! SinglePageViewController
        
    }
    
    func layoutDevice(rect: CGRect) {
  //      if UIDevice.current.userInterfaceIdiom == .pad {
            self.layoutIPad(rect: rect)

    }
    
    func layoutIPad(rect: CGRect) {
        self.pageViewController!.view.frame = rect
    }

    func toggleLightButton() {
        lightCueButton.isSelected = true
        soundCueButton.isSelected = false
        textCueButton.isSelected = false
        if expandedMenu {
            
            annotType = .light
            currentPage.annotType = annotType
            
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
            currentPage.annotType = annotType
            
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
            currentPage.annotType = annotType
            
            cueMenuShapeLayer.bringSubview(toFront: soundCueButton)
            cueMenuShapeLayer.bringSubview(toFront: textCueButton)
            
            hideCueMenu()
            
        } else {
            showCueMenu()
        }
    }
    
    func showCueMenu() {
        expandedMenu = true
        UIView.animate(withDuration: 0.2, animations: {
            let newHeight = self.menuWidth * 3
            self.cueMenuShadowHeightConstraint.constant = newHeight
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
        UIView.animate(withDuration: 0.2, animations: {
            self.cueMenuShadowHeightConstraint.constant = self.menuWidth
            let maskRect = CGRect(x: 0, y: 0, width: self.cueMenuShadowLayer.frame.width, height: self.cueMenuShadowLayer.frame.height)
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
        UIView.animate(withDuration: 0.2, animations: {
            let newHeight = self.menuWidth * 3
            self.settingsMenuShadowHeightConstraint.constant = newHeight
            let maskRect = CGRect(x: 0, y: 0, width: self.settingsMenuShadowLayer.frame.width, height: newHeight)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.settingsMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        })
        mainMenuButton.removeTarget(self, action: nil, for: .touchUpInside)
        mainMenuButton.addTarget(self, action: #selector(self.hideSettingsMenu), for: .touchUpInside)
    }
    
    func hideSettingsMenu() {
        print("hide settings here")
        UIView.animate(withDuration: 0.2, animations: {
            self.settingsMenuShadowHeightConstraint.constant = self.menuWidth
            let maskRect = CGRect(x: 0, y: 0, width: self.settingsMenuShadowLayer.frame.width, height: self.settingsMenuShadowLayer.frame.height)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.settingsMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        })
        mainMenuButton.removeTarget(self, action: nil, for: .touchUpInside)
        mainMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
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
    
    // MARK: Page View Controller Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            guard let index = (pageViewController.viewControllers?.first as! SinglePageViewController).pageNum else { return }
            print(index)
            currentPage = (pageViewController.viewControllers?.first)! as! SinglePageViewController
        }
    }
}
