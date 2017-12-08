//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/5/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit

class MyActInd : NSObject {
    
    var progressView = UIView()
    var actInd = UIActivityIndicatorView()
    
    
    override init() {
        super.init()
        progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        progressView.backgroundColor = Consts.grey_color
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        progressView.tag = 41145
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = .whiteLarge
        actInd.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        progressView.addSubview(actInd)
    }
    
    
    
    func show(_ view : UIView){
        progressView.center = view.center
        view.addSubview(progressView)
        actInd.startAnimating()
        
    }
    
    func hide(){
        progressView.removeFromSuperview()
        actInd.stopAnimating()
    }
    
    class func sharedInstance() -> MyActInd {
        struct Singleton {
            static var sharedInstance = MyActInd()
        }
        return Singleton.sharedInstance
    }
    
    
}

