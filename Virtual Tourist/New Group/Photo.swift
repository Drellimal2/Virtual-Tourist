//
//  Photos+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(title: String = "Image", imageUrl : String, image : Data? =  nil, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.imageUrl = imageUrl
            if let img = image{
                self.image = img as NSData
            }
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
