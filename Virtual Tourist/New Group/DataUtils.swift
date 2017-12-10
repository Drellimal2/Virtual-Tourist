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

func getAllPhotos(_ predicate : NSPredicate? = nil, moc : NSManagedObjectContext) -> [Photo]{
    let photosFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
    if let pred = predicate{
        photosFetch.predicate = pred
    }
    
    do {
        let fetchedPins = try moc.fetch(photosFetch) as! [Photo]
        return fetchedPins
        
    } catch {
        fatalError("Failed to fetch employees: \(error)")
    }
    
}

func getPhotosForPin(pin : Pin?, moc : NSManagedObjectContext) -> [Photo]?{
    let pred = NSPredicate(format : "pin = %@", argumentArray : [pin!])
    let photos = getAllPhotos(pred, moc: moc)
    return photos
    
}

func convertFlickrDataToPhotos (pin : Pin, data : [[String : AnyObject]], stack : CoreDataStack){
    print(data.count)
    stack.performBackgroundBatchOperation{
        (workingContext) in
        for flickrPhoto in data{
            let title = flickrPhoto[FlickrConstants.ResponseKeys.Title] as? String
            let photoUrl = flickrPhoto[FlickrConstants.ResponseKeys.MediumURL] as! String
            let photo = Photo(title: title!, imageUrl: photoUrl, context: workingContext)
            photo.pin = pin

            imageFromServerURL(photo: photo, stack: stack)
        }
    }
    
    print("data complete")
    
}

func imageFromServerURL(photo : Photo, stack : CoreDataStack) {
    
    
    

    URLSession.shared.dataTask(with: NSURL(string: photo.imageUrl!)! as URL, completionHandler: { (data, response, error) -> Void in
        
        if error != nil {
            print(error!)
            return
        }
        stack.performBackgroundBatchOperation{
            (workingContext) in
            do {
                let newphoto = try workingContext.existingObject(with: photo.objectID) as! Photo
                newphoto.image = data! as NSData
            } catch {
                print("OOPS")
            }
            
        }
        
    }).resume()
    
}
    
    
    


func deletePinPhotos(pin: Pin, stack : CoreDataStack){
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
                let newPin = workingContext.object(with: pin.objectID) as! Pin
            for photo in newPin.photos!{
                workingContext.delete(photo as! NSManagedObject)
            }
        }
    }
}

    


func deletePinPhoto(pin :Pin, photo: Photo, stack : CoreDataStack){
    
    DispatchQueue.main.async {
        stack.performBackgroundBatchOperation{
            (workingContext) in
            let newPin = workingContext.object(with: pin.objectID) as! Pin
            let photoToDelete = workingContext.object(with: photo.objectID) as! Photo
            if (newPin.photos?.contains(photoToDelete))!{
                workingContext.delete(photoToDelete as NSManagedObject)
            }
        }
    }
    
}




