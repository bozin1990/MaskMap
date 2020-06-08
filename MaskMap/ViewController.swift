//
//  ViewController.swift
//  MaskMap
//
//  Created by 陳博軒 on 2020/4/15.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var maskChildLabel: UILabel!
    @IBOutlet weak var maskAdultLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var selectedAn: MaskAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        //        詢問使用者是否可取用其位置的隱私
        locationManager.requestWhenInUseAuthorization()
        mapView.setUserTrackingMode(.none, animated: true)
        mapView.delegate = self
        let userLocation = locationManager.location?.coordinate
        
        let region = MKCoordinateRegion(center: userLocation!, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        mapView.register(MapItemAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(MaskAnnotation.self)")
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        guard let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            let decoder = MKGeoJSONDecoder()
            if let features = try? decoder.decode(data) as? [MKGeoJSONFeature] {
                
                let maskAnnotations = features.map {
                    MaskAnnotation(feature: $0)
                    
                }
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(maskAnnotations)
                    
                }
                
            }
            
            
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.showsUserLocation = true
        
    }
    
    @IBAction func showUserLocation(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        
    }
    
    @IBAction func navigationLocation(_ sender: Any) {
        guard let an = selectedAn else { return}
        let start = mapView.userLocation.coordinate
        let end = an.coordinate
        //        設定起點 終點
        direct(start: start, end: end)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //        背景執行時關閉定位功能
        locationManager.stopUpdatingLocation()
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "annotation"
        
        guard let annotation = annotation as? MaskAnnotation else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "\(MaskAnnotation.self)", for: annotation) as? MapItemAnnotationView
        if annotationView == nil {
            annotationView = MapItemAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        if let count = annotation.mask?.maskAdult, count == 0 {
            annotationView?.image = UIImage(named: "empty")
            
        } else {
            annotationView?.image = UIImage(named: "mask")
        }
        
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation as? MaskAnnotation
        selectedAn = annotation
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let timeText = formatter.string(from: annotation?.mask?.updated ?? Date())
        if (annotation != nil) {
            infoView.isHidden = false
            nameLabel.text = annotation?.mask?.name
            maskAdultLabel.text = "\(annotation?.mask?.maskAdult ?? 0)"
            maskChildLabel.text = "\(annotation?.mask?.maskChild ?? 0)"
            addressLabel.text = annotation?.mask?.address
            timeLabel.text = timeText
        }
        
        guard view is ClusterAnnotationView else { return }
        let currentSpan = mapView.region.span
        let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 2.0, longitudeDelta: currentSpan.longitudeDelta / 2.0)
        let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        mapView.setRegion(zoomed, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        infoView.isHidden = true
        selectedAn = nil
    }
    
    func direct(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let placemark_start = MKPlacemark(coordinate: start, addressDictionary: nil)
        let placemark_end = MKPlacemark(coordinate: end, addressDictionary: nil)
        //       導航需要轉成MapItem
        let mapItem_start = MKMapItem(placemark: placemark_start)
        let mapItem_end = MKMapItem(placemark: placemark_end)
        
        mapItem_start.name = "我的位置"
        let name = String(format: "(%.2f, %.2f)", end.latitude, end.longitude)
        mapItem_end.name = name
        
        let mapItems = [mapItem_start, mapItem_end]
        /* 設定導航模式：開車、走路、搭車 */
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //        開啟內建的apple map
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
    }
    
}
