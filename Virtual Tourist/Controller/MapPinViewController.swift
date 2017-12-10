//
//  MapPinViewController.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPinViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    let prefs = UserDefaults.standard
    let flickrCli = FlickrClient.sharedInstance()
    let mypintemp : UIImageView = UIImageView()
    let delegate = UIApplication.shared.delegate as! AppDelegate

    var pinStack : CoreDataStack? = nil
    var pins : [Pin] = []
    var selPin : Pin? = nil
    
    var initialCenter = CGPoint()  // The initial center point of the view
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("yeeehaaa")
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: pinStack?.context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinStack = delegate.stack

        setupTempPin()
        getPins()
        recoverOldMap()
        
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        let okAction = UIAlertAction(title: "I'm Sure", style: .destructive) { (action) in
            self.deletePins()
            self.getPins()
            
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            print("Cancelled delete operation")
            return
        }
        alert(title: "Are you sure?", message: "This will delete all pins and photos.", controller: self, actions : [okAction, cancelAction])
    }
    
    
    /*
     This uses shared preferences to recover the map to the same center and zoom as it was previously.
     */
    func recoverOldMap(){
        if let lat = prefs.value(forKey: UserDefaultKeys.CenterLat) as? Double,
            let lng = prefs.value(forKey: UserDefaultKeys.CenterLng) as? Double,
            let slat = prefs.value(forKey: UserDefaultKeys.SpanLat) as? Double,
            let slng = prefs.value(forKey: UserDefaultKeys.SpanLng) as? Double {
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let span = MKCoordinateSpan(latitudeDelta: slat, longitudeDelta: slng)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
        
        
    }
    
    func deletePins(){
        for pin in pins{
            pinStack?.context.delete(pin)
        }
        pinStack?.save()

        mapView.removeAnnotations(mapView.annotations)

        
    }
    
    func getPins(){
        pins = getAllPins(moc : (pinStack?.context)!)
        var index = 0
        for pin in pins{
            let annotation = MKPointAnnotation()
            annotation.title = String(describing: index)
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lng)
            mapView.addAnnotation(annotation)
            index += 1
            
        }
    }
    
    @IBAction func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began{
            mypintemp.isHidden = false
            movePin(fingerLoc: gestureRecognizer.location(in: mapView))
        }
        if gestureRecognizer.state == .changed{
            movePin(fingerLoc: gestureRecognizer.location(in: mapView))
        }
        
        //Using ended here so it will place the pin
        if gestureRecognizer.state != .ended {
            return
        }
        mypintemp.isHidden = true
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        DispatchQueue.main.async{
            self.pinStack?.performBackgroundBatchOperation{
                (workingContext) in
                let newPin = Pin(lat: touchMapCoordinate.latitude, lng: touchMapCoordinate.longitude, context: workingContext)
                self.getPhotos(pin: newPin)

            }
        
        }
        
    }
    
    
    func setupTempPin(){
        mypintemp.image = UIImage(named: "Pin Round")
        mypintemp.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        mypintemp.isHidden = true
        mypintemp.contentMode = .scaleAspectFit
        mapView.addSubview(mypintemp)
    }
    
    func movePin(fingerLoc : CGPoint){
        mypintemp.center.x = fingerLoc.x
        mypintemp.center.y = fingerLoc.y - (mypintemp.frame.height / 2)
    }
    
    func getPhotos(pin : Pin){
        flickrCli.getPhotos(pin: pin) { (data, error) in
            if let dat = data {
                convertFlickrDataToPhotos(pin: pin, data: dat as! [[String : AnyObject]], stack: self.pinStack!)
            } else {
                print(String(describing : error))
            }
        }
    }

}


extension MapPinViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! PhotoAlbumViewController
        dest.pin = selPin
        unsubscribeFromAllNotifications()
    }
    
}


extension MapPinViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .cyan
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    //By setting the index of the associated pin as the title for the annotation it is easy to get the correct pin.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation!
        let ind = Int(annotation.title!!)
        selPin = pins[ind!]
        performSegue(withIdentifier: "albumView", sender: self)
    }
    
    //When we change the region of the mapView i.e the center and span we save those latlong values so we can recreate the map if we were to close it at this point.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        prefs.set(mapView.centerCoordinate.latitude, forKey: UserDefaultKeys.CenterLat)
        prefs.set(mapView.centerCoordinate.longitude, forKey: UserDefaultKeys.CenterLng)
        prefs.set(mapView.region.span.latitudeDelta, forKey: UserDefaultKeys.SpanLat)
        prefs.set(mapView.region.span.longitudeDelta, forKey: UserDefaultKeys.SpanLng)

    }
  
    
}

extension MapPinViewController{
    
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
                if insert is Pin {
                    let pin = insert as! Pin
                    print(pin.dateAdded!)
                    self.pins.append(pin)
                    performUIUpdatesOnMain {
                        
                        let annotation = MKPointAnnotation()
                        let index = self.pins.count - 1
                        annotation.title = String(describing: index)
                        
                        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lng)
                        
                        self.mapView.addAnnotation(annotation)
                    
                    }
                }
                
                if insert is Photo{
                    if (insert as! Photo).image == nil{
                        print("Needs Image")
                    }
                }
            }
            
            print("Inserted \(inserts.count)")
            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("Updated \(updates.count)")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("Deleted \(deletes.count)")
        }
    }
    
    
}



