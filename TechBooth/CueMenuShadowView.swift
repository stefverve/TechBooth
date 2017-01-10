//
//  CueMenuShadowView.swift
//  TechBooth
//
//  Created by Stefan Verveniotis on 2017-01-01.
//
//

import UIKit

protocol CueMenuShadowDelegate {
    func hideCueMenu()
}

class CueMenuShadowView: UIView {
    
    var delegate: ProjectViewController?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.clipsToBounds && !self.isHidden && self.alpha > 0.0) {
            let subviews = self.subviews.reversed()
            for member in subviews {
                let subPoint = member.convert(point, from: self)
                if let result:UIView = member.hitTest(subPoint, with:event) {
                    return result;
                }
            }
        }
        delegate?.hideCueMenu()
        return nil
    }
    
}
