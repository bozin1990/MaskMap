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
protocol ViewControllerDelegate {
    func didFinishLoadMaskData(maskData:[MaskData.MaskList]?)
    func getDistance(distanceData: Distance?)
}
class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var delegate:ViewControllerDelegate?
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var maskChildLabel: UILabel!
    @IBOutlet weak var maskAdultLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var selectedAn: MaskAnnotation?
    var distances: Distance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        詢問使用者是否可取用其位置的隱私
        locationManager.delegate = self
        mapView.delegate = self
        self.delegate = (self.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? ViewControllerDelegate
        guard let url = URL(string: "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            let decoder = MKGeoJSONDecoder()
            let secDecoder = JSONDecoder()
            secDecoder.keyDecodingStrategy = .convertFromSnakeCase
            secDecoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let timeString = try decoder.singleValueContainer().decode(String.self)
                return DateFormatter.customFormatter.date(from: timeString) ?? Date()
            })
            if let features = try? decoder.decode(data) as? [MKGeoJSONFeature] {
                
                let maskAnnotations = features.map {
                    MaskAnnotation(feature: $0)
                }
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(maskAnnotations)
                }
            }
            
            if let maskData = try? secDecoder.decode(MaskData.self, from: data) {
                self.delegate?.didFinishLoadMaskData(maskData:maskData.features)
            }
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.showsUserLocation = true
        
    }
    
    @IBAction func showUserLocation(_ sender: Any) {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        } else {
            mapView.setCenter(.init(latitude: 25.033408, longitude: 121.564099), animated: true)
        }
        
        
    }
    @IBAction func navigationLocation(_ sender: Any) {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            guard let annotation = selectedAn else { return }
            let start = mapView.userLocation.coordinate
            let end = annotation.coordinate
            //        設定起點 終點
            direct(start: start, end: end)
        } else {
            return
        }
        
    }
    
    @IBAction func callPhone(_ sender: Any) {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            guard let phoneNumber = selectedAn?.mask?.phone, let url = URL(string: "tel://\(phoneNumber)") else { return }
            let alert = UIAlertController(title: "提醒您", message: "即將撥打電話\(phoneNumber)", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (_) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //        背景執行時關閉定位功能
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied, .restricted:
            let alertController = UIAlertController(title: "定位失敗", message: "請先開啟定位權限", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
            let okAction = UIAlertAction(title: "設定", style: .default) { (_) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            break
        case .authorizedWhenInUse, .authorizedAlways:
            let userLocation = locationManager.location?.coordinate
            let region = MKCoordinateRegion(center: userLocation!, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "\(MaskAnnotation.self)")
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }

}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? MaskAnnotation else {
            return nil
        }
        
        //            計算直線距離
        let loc1 = CLLocation(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude))
        
        let distance = loc1.distance(from: mapView.userLocation.location!)
        distances?.distance = distance
        self.delegate?.getDistance(distanceData: distances)
        print("123\(distances?.distance)")
        
        let identifier = "MaskAnnotation"
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if let count = annotation.mask?.maskAdult, count == 0 {
            annotationView?.markerTintColor = .systemGreen
        } else {
            annotationView?.markerTintColor = .systemRed
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
        
        if let annotation = annotation {
            infoView.isHidden = false
            nameLabel.text = annotation.mask?.name
            maskAdultLabel.text = "\(annotation.mask?.maskAdult ?? 0)"
            maskChildLabel.text = "\(annotation.mask?.maskChild ?? 0)"
            addressLabel.text = annotation.mask?.address
            timeLabel.text = timeText
            
            
            
            //            計算路徑距離
            // Okay, we've geocoded two addresses as start_placemark and end_placemark.
            //            let start = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
            //            let end = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
            
            // Now we've got start and end MKMapItems for MapKit, based on the placemarks. Build a request for
            // a route by walk.
            //            let request: MKDirections.Request = MKDirections.Request()
            //            request.source = start
            //            request.destination = end
            //            request.transportType = MKDirectionsTransportType.walking
            
            // Execute the request on an MKDirections object
            //            let directions = MKDirections(request: request)
            //            directions.calculate(completionHandler: { (response: MKDirections.Response?, error: Error?) in
            //                // Now we should have a route.
            //                if let routes = response?.routes {
            //                    let route = routes[0]
            //                    print(route.distance) // 2,307 metres.
            //                }
            //            })
            
        }
        
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

//四捨五入 取整數第x位
//extension Double {
//    func rounding(toInteger integer: Int) -> Double {
//        let integer = integer - 1
//        let numberOfDigits = pow(10.0, Double(integer))
//        return (self / numberOfDigits).rounded(.toNearestOrAwayFromZero) * numberOfDigits
//    }
//}
