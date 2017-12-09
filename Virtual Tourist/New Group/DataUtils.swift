//
//  DataUtils.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/8/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func predicateStringsFromDictionary(_ predicates : [String : Any]) -> [NSPredicate] {
    var res :[NSPredicate] =  []
    var newpred : NSPredicate?
    var predStr : String?
    for pred in predicates{
        predStr = "\(pred.key) == %@"
        newpred = NSPredicate(format: predStr!, pred.value as! CVarArg)
        res.append(newpred!)
        
    }
    
    print(res)
    return res
    
}



func predicateGet(_ preddict :[String : Any], type: String = DataConsts.predTypeAnd ) -> NSPredicate{
    let predStrings = predicateStringsFromDictionary(preddict)
    if predStrings.count > 1 {
        
        if type == DataConsts.predTypeAnd {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predStrings)
        } else {
            return NSCompoundPredicate(orPredicateWithSubpredicates: predStrings)
        }
    } else {
        return predStrings[0]
    }
}


func getAllPins(_ predicate : NSPredicate? = nil, moc : NSManagedObjectContext) -> [Pin]{
    let pinsFetch : NSFetchRequest<Pin> = Pin.fetchRequest()
    if let pred = predicate{
        pinsFetch.predicate = pred
    }
    
    do {
        let fetchedPins = try moc.fetch(pinsFetch) 
        return fetchedPins
        
    } catch {
        fatalError("Failed to fetch employees: \(error)")
    }
    
}

func getAllPhotos(_ predicate : NSPredicate? = nil, moc : NSManagedObjectContext) -> [Photos]{
    let photosFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    if let pred = predicate{
        photosFetch.predicate = pred
    }
    
    do {
        let fetchedPins = try moc.fetch(photosFetch) as! [Photos]
        return fetchedPins
        
    } catch {
        fatalError("Failed to fetch employees: \(error)")
    }
    
}

func getPhotosForPin(pin : Pin?, moc : NSManagedObjectContext) -> [Photos]?{
    let pred = NSPredicate(format : "pin = %@", argumentArray : [pin!])
    let photos = getAllPhotos(pred, moc: moc)
    return photos
    
}

func convertFlickrDataToPhotos (pin : Pin, data : [[String : AnyObject]], moc : NSManagedObjectContext){
    print(data.count)
    for flickrPhoto in data{
        let title = flickrPhoto[FlickrUtils.ResponseKeys.Title] as? String
        let photoUrl = flickrPhoto[FlickrUtils.ResponseKeys.MediumURL] as! String
//        var imageUrl = URL(string : photoUrl)
        let photo = Photos(title: title!, imageUrl: photoUrl, context: moc)
        
        photo.pin = pin
        
        imageFromServerURL(photo: photo, moc : moc)

    }
    do {
        try moc.save()
    } catch {
        print("ooops cannot save")
    }
    print("data complete")
    
}

func imageFromServerURL(photo : Photos, moc: NSManagedObjectContext) {
    
    URLSession.shared.dataTask(with: NSURL(string: photo.imageUrl!)! as URL, completionHandler: { (data, response, error) -> Void in
        
        if error != nil {
            print(error!)
            return
        }

        photo.image = data! as NSData

        do {
            try moc.save()
        } catch {
            print("ooops cannot save")
        }
    }).resume()
    
}

func deletePinPhotos(pin: Pin, moc : NSManagedObjectContext){
    for photo in pin.photos!{
        moc.delete(photo as! NSManagedObject)
        
    }
    do {
        try moc.save()
    } catch {
        print("ooops cannot save")
    }
    
}

func deletePinPhoto(pin :Pin, photo: Photos, moc : NSManagedObjectContext){
    
    if (pin.photos?.contains(photo))!{
        moc.delete(photo)
    }
    do {
        try moc.save()
        print("saved")
    } catch {
        print("ooops cannot save")
    }
}




