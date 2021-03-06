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
    
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var pinStack : CoreDataStack? = nil
    let flickrCli = FlickrClient.sharedInstance()
    var pin : Pin?
    var photos : [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPins()
        setupFlowLayout()
        setupMap()
    }
    
    
    func setupPins(){
        pinStack = delegate.stack
        photos = (pin?.photos)!.allObjects as? [Photo]
        if photos?.count == 0{
            albumView.backgroundView = NoPhotosView(frame: albumView.frame)

            DispatchQueue.main.async{
                self.pinStack?.performBackgroundBatchOperation{
                    (workingContext) in
                    let newPin = workingContext.object(with: (self.pin?.objectID)!) as! Pin
                    self.getPhotos(pin: newPin)
                    
                }
                
            }
        }

         subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: pinStack?.context)
    }
    func getPhotos(pin : Pin){
        flickrCli.getPhotos(pin: pin) { (data, error) in
            if let err = error {
                alert(title: "Error", message: err.localizedDescription, controller: self)
                performUIUpdatesOnMain {
                    self.setButtonEnabled(true)
                }
                return
            }
            if let dat = data{
                if (dat as! [[String : AnyObject]]).count == 0{
                    alert(title: "No Photos Found", message: "This location has no associated photos", controller: self)
                    performUIUpdatesOnMain {
                        self.setButtonEnabled(true)
                    }
                    return
                }
                convertFlickrDataToPhotos(pin: pin, data: dat as! [[String : AnyObject]], stack: (self.pinStack)!  )
            }
            
        }
    }
    
    func setupMap(){
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: (pin?.lat)!, longitude: (pin?.lng)!)
        let annotation = MKPointAnnotation()
        annotation.title = "Here"
        annotation.coordinate = CLLocationCoordinate2D(latitude: (pin?.lat)!, longitude: (pin?.lng)!)
        mapView.addAnnotation(annotation)
    }

    @IBAction func fetchNewCollection(_ sender: Any) {
        setButtonEnabled(false)
        deletePinPhotos(pin: pin!, stack: pinStack!)
        print("pins photos = \(String(describing: pin?.photos?.count))")
        DispatchQueue.main.async {
            self.pinStack?.performBackgroundBatchOperation{
                (workingContext) in
                let backpin = workingContext.object(with: (self.pin?.objectID)!) as! Pin
                self.getPhotos(pin: backpin)
                
            }
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
    
    func setButtonEnabled(_ enabled : Bool){
        newCollectionBtn.isEnabled = enabled
        
        if enabled {
            newCollectionBtn.alpha = 1.0

        } else {
            newCollectionBtn.alpha = 0.5
        }
        
    
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
            deletePinPhoto(pin: pin!, photo: photos![indexPath.row], stack: pinStack!)
        } else {
            print("not allowed")
        }
    }
    
    func updateAlbumView(){
        pinStack?.save()
        if photos?.count == 0{
            albumView.backgroundView = NoPhotosView(frame: albumView.frame)
        } else {
            albumView.backgroundView = nil
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
            performUIUpdatesOnMain {

                for insert in inserts{
                    if insert is Photo && (insert as! Photo).pin == self.pin{
                        self.photos?.append((insert as! Photo))
                        self.albumView.insertItems(at: [IndexPath(row : (self.photos?.count)! - 1, section : 0)])
                    }
                }
            
        
                print("[PhotoAlbum] Inserted \(inserts.count)")
                
                self.updateAlbumView()
                self.setButtonEnabled(true)
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            performUIUpdatesOnMain {

                for updt in updates{
                    if updt is Photo && (updt as! Photo).pin == self.pin {
                        let ind = self.photos?.index(of: updt as! Photo)
                        self.photos![ind!] = updt as! Photo
                            self.albumView.reloadItems(at: [IndexPath(row : ind!, section : 0)])
                    }
                    
                }
            }
            print("[PhotoAlbum] Updated \(updates.count)")

            
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            performUIUpdatesOnMain {
                
                for deleted in deletes {
                    if deleted is Photo {
                        if (self.photos?.contains(deleted as! Photo))!{
                            let ind = self.photos?.index(of: deleted as! Photo)
                            self.photos?.remove(at: ind!)
                            self.albumView.deleteItems(at: [IndexPath(row : ind!, section :0)])
                        }
                    }
                }
                print("[PhotoAlbum] Deleted \(deletes.count)")
                self.updateAlbumView()
            }
        }
    }
}

