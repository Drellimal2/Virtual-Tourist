//
//  MapPinViewController.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import MapKit

class MapPinViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    let prefs = UserDefaults.standard
    let mypintemp : UIImageView = UIImageView()
    
    var initialCenter = CGPoint()  // The initial center point of the view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupTempPin()
        recoverOldMap()
        
    }

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
        
        
        
        let annotation = MKPointAnnotation()
        annotation.title = "Place"
        annotation.coordinate = touchMapCoordinate
       
        mapView.addAnnotation(annotation)
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

}

extension MapPinViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination.description)
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
    
    
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        performSegue(withIdentifier: "albumView", sender: self)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "albumView", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.centerCoordinate)
        prefs.set(mapView.centerCoordinate.latitude, forKey: UserDefaultKeys.CenterLat)
        prefs.set(mapView.centerCoordinate.longitude, forKey: UserDefaultKeys.CenterLng)
        prefs.set(mapView.region.span.latitudeDelta, forKey: UserDefaultKeys.SpanLat)
        prefs.set(mapView.region.span.longitudeDelta, forKey: UserDefaultKeys.SpanLng)

        
//
//        print(mapView.region.span)
//        prefs.set(mapView.region.span, forKey: UserDefaultKeys.span)

    }
    
    
    
    
    
}




