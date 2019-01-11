//
//  CampusViewController.swift
//  CampusMap
//
//  Created by Chun on 2018/11/26.
//  Copyright © 2018 Nemoworks. All rights reserved.
//

import UIKit
import MapKit


class CampusViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var campus = Campus(filename: "Campus")
    var selectedOptions : [MapOptionsType] = []
    
    let HospitalLocation = CLLocationCoordinate2D(latitude: 32.115734, longitude: 118.953025)
    let LibraryLocation = CLLocationCoordinate2D(latitude: 32.114131, longitude: 118.960164)
    let GymLocation = CLLocationCoordinate2D(latitude: 32.112753, longitude: 118.956244)
    let DepartmentLocation = CLLocationCoordinate2D(latitude: 32.111045, longitude: 118.962997)
    let SuperMarketLocation = CLLocationCoordinate2D(latitude: 32.114151, longitude: 118.954858)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latDelta = campus.overlayTopLeftCoordinate.latitude - campus.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpan.init(latitudeDelta: fabs(latDelta), longitudeDelta: 0.0)
        let region = MKCoordinateRegion.init(center: campus.midCoordinate, span: span)
        
        mapView.region = region
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
    }
    
    
    // MARK: Helper methods
    func loadSelectedOptions() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        for option in selectedOptions {
            switch (option) {
            case .mapPOIs:
                self.addPOIs()
            case .mapBoundary:
                self.addBoundary()
            case .mapNavigationLibraryToHospital:
                self.addNavigationLibraryToHospital()
            case .mapNavigationSupermarketToDepartment:
                self.addNavigationSupermarketToDepartment()
            case .mapNavigationGymToHospital:
                self.addNavigationGymToHospital()
            }
        }
    }
    
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        guard let vc = exitSegue.source as? MapOptionsViewController else { return }
        selectedOptions = vc.selectedOptions
        loadSelectedOptions()
    }
    
    
    //    func addOverlay() {
    //        let overlay = ParkMapOverlay(park: park)
    //        mapView.addOverlay(overlay)
    //    }
    //
    //case mapNavigationLibraryToHospital
    //case mapNavigationSupermarketToDepartment
    //case mapNavigationGymToHospital
    
    func addNavigationLibraryToHospital() {
        let sourceLocation = LibraryLocation
        let destinationLocation = HospitalLocation
        
        let sourceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourceMark)
        directionRequest.destination = MKMapItem(placemark: destinationMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        //Closure
        directions.calculate { (response, error) in
            guard let directionResponse = response else{
                if let error = error{
                    print(error.localizedDescription)
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    
    
    func addNavigationSupermarketToDepartment() {
        let sourceLocation = SuperMarketLocation
        let destinationLocation = DepartmentLocation
        
        let sourceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourceMark)
        directionRequest.destination = MKMapItem(placemark: destinationMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        //Closure
        directions.calculate { (response, error) in
            guard let directionResponse = response else{
                if let error = error{
                    print(error.localizedDescription)
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    func addNavigationGymToHospital() {
        let sourceLocation = GymLocation
        let destinationLocation = HospitalLocation
        
        let sourceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourceMark)
        directionRequest.destination = MKMapItem(placemark: destinationMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        //Closure
        directions.calculate { (response, error) in
            guard let directionResponse = response else{
                if let error = error{
                    print(error.localizedDescription)
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    
    func addBoundary() {
        mapView.addOverlay(MKPolygon(coordinates: campus.boundary, count: campus.boundary.count))
    }
    
    func addPOIs() {
        guard let pois = Campus.plist("CampusPOI") as? [[String : String]] else { return }
        
        for poi in pois {
            let coordinate = Campus.parseCoord(dict: poi, fieldName: "location")
            let title = poi["name"] ?? ""
            let typeRawValue = Int(poi["type"] ?? "0") ?? 0
            let type = POIType(rawValue: typeRawValue) ?? .misc
            let subtitle = poi["subtitle"] ?? ""
            let annotation = POIAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - MKMapViewDelegate
extension CampusViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.red
            lineView.lineWidth = CGFloat(4.0)
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.blue
            polygonView.lineWidth = CGFloat(3.0)
            return polygonView
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = POIAnnotationView(annotation: annotation, reuseIdentifier: "POI")
        annotationView.canShowCallout = true
        return annotationView
    }
}
