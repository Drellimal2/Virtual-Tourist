//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/9/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
