//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumView: UICollectionView!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var pinStack : CoreDataStack? = nil
    
    let flickrCli = FlickrClient.sharedInstance()
    var pin : Pin?
    var backgroundPin : Pin?
    var photos : [Photos]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        albumView.delegate = self
        albumView.dataSource = self
        setupPins()
        
        setupFlowLayout()
        setupMap()
    }
    
    func setupPins(){
        pinStack = delegate.stack
        
        let pred = NSPredicate(format: "dateAdded = %@", argumentArray: [pin?.dateAdded as Any])
        let backgroundPins = getAllPins(pred, moc: (pinStack?.backgroundContext)!)
        if backgroundPins.count > 0{
            backgroundPin = backgroundPins[0]
            photos = getPhotosForPin(pin: backgroundPin, moc: (pinStack?.context)!)

        }
        if photos?.count != pin?.photos?.count {
            photos = pin?.photos?.allObjects as? [Photos]

        }
        
         subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: pinStack?.context)
    }
    
    func setupMap(){
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: (pin?.lat)!, longitude: (pin?.lng)!)
        let annotation = MKPointAnnotation()
        annotation.title = "Here"
        annotation.coordinate = CLLocationCoordinate2D(latitude: (pin?.lat)!, longitude: (pin?.lng)!)
        mapView.addAnnotation(annotation)
    }

    @IBAction func fetchNewCollection(_ sender: Any) {
        deletePinPhotos(pin: backgroundPin!, moc: (pinStack?.backgroundContext)!)
        print("pins photos = \(String(describing: pin?.photos?.count))")
        let pred = NSPredicate(format: "dateAdded = %@", argumentArray: [pin?.dateAdded as Any])
        let backgroundPins = getAllPins(pred, moc: (pinStack?.backgroundContext)!)
        if backgroundPins.count > 0 {
            backgroundPin = backgroundPins[0]
        
            flickrCli.getPhotos(pin: backgroundPin!) { (data, error) in
                if let dat = data{
                    print((dat as! [[String : AnyObject]]).count)
                    convertFlickrDataToPhotos(pin: self.backgroundPin!, data: dat as! [[String : AnyObject]], moc: (self.pinStack?.backgroundContext)!  )
                }
            }
        } else {
            print("could not gte pins")
        }
        
    }
    
    func setupFlowLayout(){
        let space:CGFloat = 8.0
        let dimension = (albumView.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.scrollDirection = .vertical
    }
    

}

extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinPic", for: indexPath) as! AlbumCollectionViewCell
        if let imageData = photos![indexPath.row].image{
            let image = UIImage(data: imageData as Data)
            cell.imageView.image = image
        } else {
            cell.imageView.image = Images.placeholder
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
        if cell.imageView.image != Images.placeholder{
            deletePinPhoto(pin: pin!, photo: photos![indexPath.row], moc: (pinStack?.context)!)
        } else {
            print("not allowed")
        }
    }
   
}

extension PhotoAlbumViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .cyan
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    

}

extension PhotoAlbumViewController {
    func subscribeToNotification(_ name: NSNotification.Name, selector: Selector, object : Any? = nil ) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: object)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            for insert in inserts{
                if insert is Photos && (insert as! Photos).pin == pin{
                    photos?.append((insert as! Photos))
                    albumView.insertItems(at: [IndexPath(row : (photos?.count)! - 1, section : 0)])
                }
            }
            print("Inserted \(inserts.count)")

            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            for updt in updates{
                if updt is Photos && (updt as! Photos).pin == pin {
                    let ind = photos?.index(of: updt as! Photos)
                    photos![ind!] = updt as! Photos
                    albumView.reloadItems(at: [IndexPath(row : ind!, section : 0)])
                    
                }
            }
            print("Updated \(updates.count)")

            
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            for deleted in deletes {
                if deleted is Photos {
                    if (photos?.contains(deleted as! Photos))!{
                        let ind = photos?.index(of: deleted as! Photos)
                        photos?.remove(at: ind!)
                        albumView.deleteItems(at: [IndexPath(row : ind!, section :0)])
                    }
                }
            }
            print("Deleted \(deletes.count)")
            
        }
    }
}

