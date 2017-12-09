//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    convenience init(lat: Double, lng : Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.lng = lng
            self.dateAdded = Date() as NSDate
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    
}
