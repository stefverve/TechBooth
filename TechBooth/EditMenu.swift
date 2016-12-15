//
//  EditMenu.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2016-12-15.
//
//

import UIKit

class EditMenu: UIView {
    
    enum CueType: Int {
        case Light
        case Sound
        case Text
        case None
    }
    
    var cueType = CueType.None

    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBAction func cueButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            self.cueType = .None
        } else {
            soundButton.isSelected = false
            lightButton.isSelected = false
            textButton.isSelected = false
            sender.isSelected = true
            self.cueType = EditMenu.CueType(rawValue: sender.tag)!
        }
    }
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
