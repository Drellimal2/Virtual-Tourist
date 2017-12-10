//
//  NoPhotosView.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/9/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit

class NoPhotosView: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup(){
        self.text = "No Photos Available"
        self.textAlignment = .center
        self.font = UIFont(name: "System", size: 33.0)
        self.textColor = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 0.80)
    }

}
