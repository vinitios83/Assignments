//
//  ViewController.swift
//  Lab5_GPS_Map
//
//   on 24/03/22.
//

import UIKit
import CoreLocation
import MapKit
import CoreMotion


class ViewController: UIViewController {

    @IBOutlet weak var lbl_CurrentSpeedValue: UILabel!
    @IBOutlet weak var lbl_MaxSpeedValue: UILabel!
    @IBOutlet weak var lbl_AverageSpeedValue: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    @IBOutlet weak var lbl_MaxAcelerationValue: UILabel!
    @IBOutlet weak var vw_SpeedLimit: UIView!
    @IBOutlet weak var mapvw: MKMapView!
    @IBOutlet weak var vw_Footer: UIView!
    
    //CoreLocation
    let locationManager = CLLocationManager()
    var startLocation : CLLocation?
    var location : CLLocation?
    var currentSpeed : Double = 0.0
    var maxSpeed : Double = 0.0
    
    //CoreMotion
    var motionManager = CMMotionManager()
    var destX:Double  = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trip Summary"
        self.vw_Footer.backgroundColor = UIColor.lightGray
        self.vw_SpeedLimit.backgroundColor = UIColor.red
        self.vw_SpeedLimit.isHidden = true
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        if motionManager.isAccelerometerAvailable {
                // 2
            motionManager.accelerometerUpdateInterval = 1.0
                motionManager.startAccelerometerUpdates(to: .main) {
                    (data, error) in
                    guard let data = data, error == nil else {
                        return
                    }

                    // 3
                    self.destX = CGFloat(data.acceleration.x * 9.81)
                    if self.destX > 0 {
                        self.lbl_MaxAcelerationValue.text = "\(self.destX.rounded(toPlaces: 2)) m/s^2"
                    }
                }
            }
    }

    func UpdateSpeedValues() {
        if self.currentSpeed > 0 {
            self.lbl_CurrentSpeedValue.text = "\(currentSpeed.rounded(toPlaces: 2)) km/h"
        }else {
            self.lbl_CurrentSpeedValue.text = "0 km/h"
        }
        if self.currentSpeed > self.maxSpeed {
            self.maxSpeed = currentSpeed
            self.lbl_MaxSpeedValue.text = "\(maxSpeed.rounded(toPlaces: 2)) km/h"
        }
        if currentSpeed >= 115.0 {
            self.vw_SpeedLimit.isHidden = false
        }else {
            self.vw_SpeedLimit.isHidden = true
        }
        self.lbl_AverageSpeedValue.text = "\((self.maxSpeed/2.0).rounded(toPlaces: 2)) km/h"
        
        if let startLocation = self.startLocation , let endLocation = self.location {
            let distance = endLocation.distance(from: startLocation)
            self.lbl_Distance.text = "\((distance/1000).rounded(toPlaces: 2)) km"
        }
         
    }
    
    //View Actions
    @IBAction func StartTripBtnClick(_ sender: Any) {
        self.locationManager.startUpdatingLocation()
        self.vw_Footer.backgroundColor = UIColor.green
    }
    
    @IBAction func StopTripBtnClick(_ sender: Any) {
        self.locationManager.stopUpdatingLocation()
        self.vw_Footer.backgroundColor = UIColor.lightGray
    }
    
}
extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            if self.startLocation == nil {
                self.startLocation = location
            }
            self.location = location
            self.mapvw.centerToLocation(location)
            self.updateLocationOnMap(to: location, with: "Current Location")
            self.currentSpeed = location.speed*3.6
            self.UpdateSpeedValues()
        }
    }
    func updateLocationOnMap(to location: CLLocation, with title: String?) {
            
            let point = MKPointAnnotation()
            point.title = title
            point.coordinate = location.coordinate
            self.mapvw.removeAnnotations(self.mapvw.annotations)
            self.mapvw.addAnnotation(point)

            let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapvw.setRegion(viewRegion, animated: true)
        }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
