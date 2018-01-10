//
//  ViewController.swift
//  VirtualTourist
//
//  Created by user on 12/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit

enum EditState {
    case editing, normal
}

class MapViewController: CustomViewController {
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
//    var barButtonItem: UIBarButtonItem!
    
    var currentEditState: EditState! = .editing
    
    var selectedAnnotation: MKAnnotation!
    
    let buttonHeigh: CGFloat = 40
    
    var annotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        barButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, targetViewController: self, action: #selector(MapViewController.editButtonOnTap))
        
        buttonHeightConstraint.constant = .leastNormalMagnitude
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }

    @objc func editButtonOnTap() {
        if currentEditState == .normal {
            
            buttonHeightConstraint.constant = buttonHeigh
            currentEditState = .editing
        } else {
            
            buttonHeightConstraint.constant = .leastNormalMagnitude
            currentEditState = .normal
        }
        
    }
    
    @objc func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let coordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
            pinView?.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        selectedAnnotation = view.annotation
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let bbox = Util.getBoundingBox(for: selectedAnnotation.coordinate.latitude, and: selectedAnnotation.coordinate.longitude)
        
        let performToDetailViewController: (MKAnnotation, [FlickrPhoto]) -> Void = {  annotation, photos in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pinDetailViewController = storyboard.instantiateViewController(withIdentifier: "PinDetailViewControllerID") as! PINDetailViewController
            pinDetailViewController.selectedAnnotation = annotation
            pinDetailViewController.photos = photos
            pinDetailViewController.bbox = bbox
            
            self.navigationController?.pushViewController(pinDetailViewController, animated: true)
            
        }
        
        FlickrHandler.shared().getPhotos(with: bbox, in: self, onCompletion: { photos in
            performToDetailViewController(self.selectedAnnotation, photos)
        })
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.coordinate)
    }
}

