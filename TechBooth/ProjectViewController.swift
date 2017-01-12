//
//  PDFPageViewController.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-14.
//
//

import UIKit

class ProjectViewController: UIViewController, UIPageViewControllerDelegate, UITableViewDataSource, CueMenuShadowDelegate {
    
    // MARK: Properties
    
    var pageViewController: UIPageViewController?
    var lightCueButton = UIButton()
    var soundCueButton = UIButton()
    var textCueButton = UIButton()
    var cueMenuShadowLayer = CueMenuShadowView()
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
    
    var settingsMenuButton = UIButton()
    var mainMenuButton = UIButton()
    var presentationButton = UIButton()
    
    var soundTableButton = UIButton()
    var lightTableButton = UIButton()
    var noteTableButton = UIButton()
    
    var menuWidth: CGFloat!
    var expandedCueMenu = false
    var annotType: AnnotType = .light
    var cueArray: Array<Annotation>!
    
    var currentPage: SinglePageViewController!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: UIViewController Overrides
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        menuWidth = self.view.frame.size.width * 0.12
		
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController?.delegate = self
        
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
        
        self.layoutDevice(rect: self.view.bounds)
        self.modelController.pageViewRect = self.pageViewController?.view.bounds
        let startingViewController: SinglePageViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        startingViewController.view.frame = (self.pageViewController?.view.bounds)!
        
        startingViewController.allowEdits = true
        
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
        lightCueButton.imageEdgeInsets = UIEdgeInsetsMake(menuWidth/12, menuWidth/12, menuWidth/12, menuWidth/12)
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
        
        lightCueButton.backgroundColor = UIColor.darkGray
        lightCueButton.imageView?.tintColor = UIColor.init(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        soundCueButton.backgroundColor = UIColor.darkGray
        soundCueButton.imageView?.tintColor = UIColor.orange
        textCueButton.backgroundColor = UIColor.darkGray
        textCueButton.imageView?.tintColor = UIColor.lightGray
        
        self.view.addSubview(settingsMenuShadowLayer)
        settingsMenuShadowLayer.addSubview(settingsMenuShapeLayer)
        
        settingsMenuShadowHeightConstraint = settingsMenuShadowLayer.heightAnchor.constraint(equalToConstant: menuWidth)
        settingsMenuShadowHeightConstraint.isActive = true
        settingsMenuShadowLayer.widthAnchor.constraint(equalToConstant: menuWidth).isActive = true
        settingsMenuShadowLayer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        settingsMenuShadowLayer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        settingsMenuShadowLayer.layer.shadowRadius = 3
        settingsMenuShadowLayer.layer.shadowColor = UIColor.black.cgColor
        settingsMenuShadowLayer.layer.shadowOpacity = 0.8
        settingsMenuShadowLayer.layer.shadowOffset = CGSize.zero
        
        settingsMenuShapeLayer.bottomAnchor.constraint(equalTo: settingsMenuShadowLayer.bottomAnchor).isActive = true
        settingsMenuShapeLayer.trailingAnchor.constraint(equalTo: settingsMenuShadowLayer.trailingAnchor).isActive = true
        settingsMenuShapeLayer.widthAnchor.constraint(equalTo: settingsMenuShadowLayer.widthAnchor).isActive = true
        settingsMenuShapeLayer.heightAnchor.constraint(equalTo: settingsMenuShadowLayer.heightAnchor).isActive = true
        
        path = UIBezierPath(roundedRect: cueMenuShapeLayer.bounds, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: menuWidth/10, height: menuWidth/10))
        mask = CAShapeLayer()
        mask.path = path.cgPath
        settingsMenuShapeLayer.layer.mask = mask

        settingsMenuShapeLayer.backgroundColor = UIColor(white: 0.85, alpha: 1)
        settingsMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        settingsMenuButton.backgroundColor = UIColor.red
        
        settingsMenuShadowLayer.translatesAutoresizingMaskIntoConstraints = false
        settingsMenuShapeLayer.translatesAutoresizingMaskIntoConstraints = false
        settingsMenuButton.translatesAutoresizingMaskIntoConstraints = false
        mainMenuButton.translatesAutoresizingMaskIntoConstraints = false
        presentationButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingsMenuShapeLayer.addSubview(presentationButton)
        settingsMenuShapeLayer.addSubview(mainMenuButton)
        settingsMenuShapeLayer.addSubview(settingsMenuButton)
        
        settingsMenuButton.centerXAnchor.constraint(equalTo: settingsMenuShapeLayer.centerXAnchor).isActive = true
        settingsMenuButton.widthAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor).isActive = true
        settingsMenuButton.bottomAnchor.constraint(equalTo: settingsMenuShapeLayer.bottomAnchor).isActive = true
        settingsMenuButton.heightAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        settingsMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
        settingsMenuButton.backgroundColor = UIColor.darkGray
        settingsMenuButton.setImage(UIImage(named: "menu-button"), for: .normal)
        settingsMenuButton.imageView?.tintColor = UIColor.lightGray
        settingsMenuButton.imageEdgeInsets = UIEdgeInsetsMake(menuWidth/4, menuWidth/4, menuWidth/4, menuWidth/4)
        
        mainMenuButton.centerYAnchor.constraint(equalTo: settingsMenuShapeLayer.centerYAnchor).isActive = true
        mainMenuButton.widthAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor).isActive = true
        mainMenuButton.centerXAnchor.constraint(equalTo: settingsMenuShapeLayer.centerXAnchor).isActive = true
        mainMenuButton.heightAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        mainMenuButton.backgroundColor = UIColor.darkGray
        mainMenuButton.addTarget(self, action: #selector(dismissProjectView), for: .touchUpInside)
        mainMenuButton.setImage(UIImage(named: "back-button"), for: .normal)
        mainMenuButton.imageView?.tintColor = UIColor.lightGray
        mainMenuButton.imageEdgeInsets = UIEdgeInsetsMake(menuWidth*0.2, menuWidth*0.15, menuWidth*0.1, menuWidth*0.15)
        
        presentationButton.centerXAnchor.constraint(equalTo: settingsMenuShapeLayer.centerXAnchor).isActive = true
        presentationButton.widthAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor).isActive = true
        presentationButton.topAnchor.constraint(equalTo: settingsMenuShapeLayer.topAnchor).isActive = true
        presentationButton.heightAnchor.constraint(equalTo: settingsMenuShapeLayer.widthAnchor, multiplier: 1).isActive = true
        
        presentationButton.backgroundColor = UIColor.darkGray
        presentationButton.addTarget(self, action: #selector(presentationMode), for: .touchUpInside)
        presentationButton.setImage(UIImage(named: "spotlight"), for: .normal)
        presentationButton.imageView?.tintColor = UIColor.lightGray
//        presentationButton.imageEdgeInsets = UIEdgeInsetsMake(menuWidth*0.9, menuWidth*0.9, menuWidth*0.9, menuWidth*0.9)
        presentationButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        let presentationButtonScaleFactor = (menuWidth*0.8)/(presentationButton.imageView?.frame.width)!
        presentationButton.imageView?.transform = CGAffineTransform(scaleX: presentationButtonScaleFactor, y: -presentationButtonScaleFactor)
        
        
        lightTableButton.frame = CGRect(x: 0, y: 0, width: menuWidth * 0.8, height: menuWidth * 0.6)
        lightTableButton.backgroundColor = UIColor.lightGray
        lightTableButton.addTarget(self, action: #selector(self.showCueTable(_:)), for: .touchUpInside)
        
        soundTableButton.frame = CGRect(x: 0, y: 0, width: menuWidth * 0.8, height: menuWidth * 0.6)
        soundTableButton.backgroundColor = UIColor.lightGray
        soundTableButton.addTarget(self, action: #selector(self.showCueTable(_:)), for: .touchUpInside)
        
        noteTableButton.frame = CGRect(x: 0, y: 0, width: menuWidth * 0.8, height: menuWidth * 0.6)
        noteTableButton.backgroundColor = UIColor.lightGray
        noteTableButton.addTarget(self, action: #selector(self.showCueTable(_:)), for: .touchUpInside)
        
        
        currentPage = (self.pageViewController?.viewControllers?.first)! as! SinglePageViewController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cueMenuShadowLayer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        expandedCueMenu = false
    }
    
    func presentationMode() {
        
        print("Showtime!")
        hideSettingsMenu()
        performSegue(withIdentifier: "showTime", sender: nil)
        
    }
    
    func dismissProjectView() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Layout functions
    
    func layoutDevice(rect: CGRect) {
  //      if UIDevice.current.userInterfaceIdiom == .pad {
            self.layoutIPad(rect: rect)

    }
    
    func layoutIPad(rect: CGRect) {
        self.pageViewController!.view.frame = rect
        
    }
    
    // MARK: Cue Menu functions
    
    func showCueMenu() {
        expandedCueMenu = true
        UIView.animate(withDuration: 0.2, animations: {
            let newHeight = self.menuWidth * 3
            self.cueMenuShadowHeightConstraint.constant = newHeight
            let maskRect = CGRect(x: 0, y: 0, width: self.cueMenuShadowLayer.frame.width, height: newHeight)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.cueMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            
            let lightSubMenu = UIView(frame: CGRect(x: 0, y: self.lightCueButton.frame.origin.y + (self.menuWidth * 0.2), width: self.menuWidth * 2.1, height: self.menuWidth * 0.6))
            lightSubMenu.tag = 1
            lightSubMenu.addSubview(self.lightTableButton)
            
            let soundSubMenu = UIView(frame: CGRect(x: 0, y: self.soundCueButton.frame.origin.y + (self.menuWidth * 0.2), width: self.menuWidth * 2.1, height: self.menuWidth * 0.6))
            soundSubMenu.tag = 1
            soundSubMenu.addSubview(self.soundTableButton)
            
            let textSubMenu = UIView(frame: CGRect(x: 0, y: self.textCueButton.frame.origin.y + (self.menuWidth * 0.2), width: self.menuWidth * 2.1, height: self.menuWidth * 0.6))
            textSubMenu.tag = 1
            textSubMenu.addSubview(self.noteTableButton)
            
            self.cueMenuShadowLayer.insertSubview(lightSubMenu, belowSubview: self.cueMenuShapeLayer)
            self.cueMenuShadowLayer.insertSubview(soundSubMenu, belowSubview: self.cueMenuShapeLayer)
            self.cueMenuShadowLayer.insertSubview(textSubMenu, belowSubview: self.cueMenuShapeLayer)
            
            UIView.animate(withDuration: 0.2, animations: {
                lightSubMenu.frame.origin.x -= self.menuWidth * 0.8
                soundSubMenu.frame.origin.x -= self.menuWidth * 0.8
                textSubMenu.frame.origin.x -= self.menuWidth * 0.8
            }, completion: {
                (value: Bool) in
            })
        })
    }
    
    func hideCueMenu() {
        expandedCueMenu = false
        UIView.animate(withDuration: 0.2, animations: {
            self.cueMenuShadowHeightConstraint.constant = self.menuWidth
            let maskRect = CGRect(x: 0, y: 0, width: self.cueMenuShadowLayer.frame.width, height: self.cueMenuShadowLayer.frame.height)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.cueMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
            self.cueMenuShadowLayer.subviews.filter({$0.tag == 1}).forEach({$0.frame.origin.x += self.menuWidth * 1.6})
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
            self.cueMenuShadowLayer.subviews.filter({$0.tag == 1}).forEach({$0.removeFromSuperview()})
        })
    }
    
    
    func toggleLightButton() {
        lightCueButton.isSelected = true
        soundCueButton.isSelected = false
        textCueButton.isSelected = false
        if expandedCueMenu {
            
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
        if expandedCueMenu {
            
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
        if expandedCueMenu {
            
            annotType = .note
            currentPage.annotType = annotType
            
            cueMenuShapeLayer.bringSubview(toFront: soundCueButton)
            cueMenuShapeLayer.bringSubview(toFront: textCueButton)
            
            hideCueMenu()
            
        } else {
            showCueMenu()
        }
    }
    
    // MARK: Settings Menu functions
    
    func showSettingsMenu() {
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
        settingsMenuButton.removeTarget(self, action: nil, for: .touchUpInside)
        settingsMenuButton.addTarget(self, action: #selector(self.hideSettingsMenu), for: .touchUpInside)
    }
    
    func hideSettingsMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.settingsMenuShadowHeightConstraint.constant = self.menuWidth
            let maskRect = CGRect(x: 0, y: 0, width: self.settingsMenuShadowLayer.frame.width, height: self.settingsMenuShadowLayer.frame.height)
            let path = UIBezierPath(roundedRect: maskRect, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize(width: self.menuWidth/10, height: self.menuWidth/10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.settingsMenuShapeLayer.layer.mask = mask
            self.view.layoutIfNeeded()
        })
        settingsMenuButton.removeTarget(self, action: nil, for: .touchUpInside)
        settingsMenuButton.addTarget(self, action: #selector(self.showSettingsMenu), for: .touchUpInside)
    }
    
    func showCueTable(_ sender: UIButton) {
        print("Light Table goes here!")
        if sender == lightTableButton {
            cueArray = DataManager.share.fetchSortedAnnotationsOf(type: AnnotType.light.rawValue)
        } else if sender == soundTableButton {
            cueArray = DataManager.share.fetchSortedAnnotationsOf(type: AnnotType.sound.rawValue)
        } else if sender == noteTableButton {
            cueArray = DataManager.share.fetchSortedAnnotationsOf(type: AnnotType.note.rawValue)
        }
        let tableWidth = view.frame.width/2
        let cueTableShadowLayer = UIView(frame: CGRect(x: -tableWidth, y: view.frame.height*0.2, width: tableWidth, height: view.frame.height*0.6))
        let cueTable = UITableView(frame: cueTableShadowLayer.bounds)
        cueTable.dataSource = self
        view.addSubview(cueTableShadowLayer)
        cueTableShadowLayer.addSubview(cueTable)
        cueTable.layer.cornerRadius = 10
        cueTableShadowLayer.layer.shadowRadius = 3
        cueTableShadowLayer.layer.shadowColor = UIColor.black.cgColor
        cueTableShadowLayer.layer.shadowOpacity = 0.8
        cueTableShadowLayer.layer.shadowOffset = CGSize.zero
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.removeTableView(gesture:)))
        swipeLeft.direction = .left
        cueTable.addGestureRecognizer(swipeLeft)
        UIView.animate(withDuration: 0.3, animations: {
            cueTableShadowLayer.frame.origin.x = 0
        })
        hideCueMenu()
    }
    
    // MARK: Page View Controller Delegate Methods
    
    var modelController: ModelController {
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }
    
    var _modelController: ModelController? = nil
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            guard let index = (pageViewController.viewControllers?.first as! SinglePageViewController).pageNum else { return }
            print(index)
            currentPage = (pageViewController.viewControllers?.first)! as! SinglePageViewController
        }
    }
    
    // MARK: Table View Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "myCell")
        cell.textLabel?.text = "\(cueArray[indexPath.row].pageNumber).\(cueArray[indexPath.row].cueNum) - \(cueArray[indexPath.row].cueDescription!)"
        
        return cell
    }
    
    func removeTableView(gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            gesture.view?.superview?.frame.origin.x -= self.view.frame.width/2
        }, completion: {
            (value:Bool) in
            gesture.view?.superview?.removeFromSuperview()
        })
    }
}
