//
//  DataUtils.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct UserDefaultKeys {
    
    static let span = "span"
    static let center = "center"
    static let CenterLat = "center_lat"
    static let CenterLng = "center_lng"
    static let SpanLat = "span_delta_lat"
    static let SpanLng = "span_delta_lng"
   
}

struct EntityKeys {
    static let lat = "lat"
    static let lng = "lng"
    static let date = "dateAdded"
    static let imageURL = "imageUrl"
}

struct DataConsts {
    static let predTypeOr = "or"
    static let predTypeAnd = "and"
    
}

struct Images {
    static let placeholder = UIImage(named: "Placeholder")
}



func alert(title : String, message : String, controller : UIViewController, actions : [UIAlertAction] = []){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if actions.count == 0{
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    } else {
        for action in actions{
            alert.addAction(action)
        }
    }
    controller.present(alert, animated: true, completion: nil)
}



