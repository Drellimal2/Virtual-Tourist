//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Dane Miller on 12/7/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumView: UICollectionView!
    
    var pin : Pin?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        albumView.delegate = self
        albumView.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func fetchNewCollection(_ sender: Any) {
    }
    

}

extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell
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
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    
    
}
