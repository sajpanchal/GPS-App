//
//  ViewController.swift
//  GPS
//
//  Created by saj panchal on 2020-02-18.
//  Copyright © 2020 saj panchal. All rights reserved.
//

import UIKit
import CoreLocation   //CL any class in the library
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate
{
    let lm = CLLocationManager()  //function will provide the location
    struct Speed
    {
        var lastMax: Double = 0.0
        var last: Double = 0.0
        var current: Double = 0.0
        var max: Double = 0.0
        var avg: Double = 0.0
        var total: Double = 0.0
        init(lastMax:Double, last:Double, current:Double, max:Double, avg:Double, total:Double)
        {
            self.lastMax = lastMax
            self.last = last
            self.current = current
            self.max = max
            self.avg = avg
            self.total = total
        }
    }
    
    struct Acceleration
    {
        var max: Double
        var current: Double
        var last: Double
        var lastMax: Double
        init (max:Double, current:Double, last:Double, lastMax:Double)
        {
            self.max = max
            self.current = current
            self.last = last
            self.lastMax = lastMax
        }
    }
    
    struct Distance
    {
        var total: Double = 0.0
        var diff: Double = 0.0
        var belowOverSpeed: Double = 0.0
        init(total:Double, diff:Double, belowOverSpeed:Double)
        {
            self.total = total
            self.diff = diff
            self.belowOverSpeed = belowOverSpeed
        }
    }
    
    var speed = Speed(lastMax: 0.0, last: 0.0, current: 0.0, max: 0.0, avg: 0.0, total: 0.0)
    var distance = Distance(total: 0.0, diff: 0.0, belowOverSpeed: 0.0)
    var acceleration = Acceleration(max: 0.0, current: 0.0, last: 0.0, lastMax: 0.0)
    var currentLocation: CLLocation?
    var lastLocation: CLLocation?
    var index: Int = 1
   
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var startTripBtn: UIButton!
    @IBOutlet weak var stopTripBtn: UIButton!
    @IBOutlet weak var currentSpeedLbl: UILabel!
    @IBOutlet weak var maxSpeedLbl: UILabel!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var avgSpeedLbl: UILabel!
    @IBOutlet weak var DistanceLbl: UILabel!
    @IBOutlet weak var maxAccelarationLbl: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        lm.delegate = self //assign viewcontroller value to lm delegate
        lm.requestWhenInUseAuthorization()
        ResetData()
        bottomBarView.backgroundColor = .lightGray
        topBarView.backgroundColor = .lightGray
    }
    
    @IBAction func startTripBtn(_ sender: Any)
    {
        startTripBtn.tag = 1
        startTripBtn.tag = 0
        lm.startUpdatingLocation()
        mapview.showsUserLocation = true
        currentSpeedLbl.text = String(speed.current)
        maxSpeedLbl.text = String(speed.max)
        avgSpeedLbl.text = String(speed.avg)
        DistanceLbl.text = String(distance.total)
        maxAccelarationLbl.text = String(acceleration.max)
        bottomBarView.backgroundColor = .green
    }
    
    @IBAction func stopTripBtn(_ sender: Any)
    {
        startTripBtn.tag = 0
        stopTripBtn.tag = 1
        mapview.showsUserLocation = false
        lm.stopUpdatingLocation()
        bottomBarView.backgroundColor = .lightGray
        ResetData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            currentLocation = location  //set current location
            if(lastLocation != nil) //if last location is empty skip it.
            {
                speed.current = location.speed
                speed.total += speed.current
                speed.avg = speed.total/Double(index)
                index += 1
                distance.diff = currentLocation!.distance(from: lastLocation!)
                speed.max = (speed.current >= speed.lastMax) ? speed.current : speed.lastMax
                acceleration.current = abs(speed.current - speed.last)
                acceleration.max = (acceleration.current >= acceleration.lastMax) ? acceleration.current : acceleration.lastMax
                distance.total = distance.total + Double(distance.diff)
                DisplayData()
                if((speed.current*3.6) >= 115.0)
                {
                    topBarView.backgroundColor = .red
                }
                else
                {
                    topBarView.backgroundColor = .lightGray
                    distance.belowOverSpeed +=  currentLocation!.distance(from: lastLocation!)
                    print("below 115km/h total travel:\(distance.belowOverSpeed/1000)")
                }
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                if(startTripBtn.tag == 1)
                {
                    mapview.setRegion(region, animated: true)
                }
                else if (stopTripBtn.tag == 1)
                {
                    mapview.setRegion(region, animated: false)
                }
                else
                {
                    mapview.setRegion(region, animated: false)
                }
            }
        }
        lastLocation = currentLocation
        speed.last = speed.current // set current location as last location
        speed.lastMax = speed.max
        acceleration.last = acceleration.current
        acceleration.lastMax = acceleration.max
    }
    
    func DisplayData() -> Void
    {
        DistanceLbl.text = String(format:"%.2f", (distance.total/1000)) + "km"
        currentSpeedLbl.text = String(format:"%.2f", (speed.current*3.6)) + "km/h"
        maxSpeedLbl.text = String(format:"%.2f", (speed.max*3.6)) + "km/h"
        avgSpeedLbl.text = String(format:"%.2f", (speed.avg*3.6)) + "km/h"
        maxAccelarationLbl.text = String(format:"%.2f", acceleration.max) + "m/s^2"
    }
    func ResetData() -> Void
    {
        DistanceLbl.text = "0.00 km"
        currentSpeedLbl.text = "0.00 km/h"
        maxSpeedLbl.text = "0.00 km/h"
        avgSpeedLbl.text = "0.00 km/h"
        maxAccelarationLbl.text = "0.00 m/s^2"
        speed = Speed(lastMax: 0.0, last: 0.0, current: 0.0, max: 0.0, avg: 0.0, total: 0.0)
        acceleration = Acceleration(max: 0.0, current: 0.0, last: 0.0, lastMax: 0.0)
        distance = Distance(total: 0.0, diff: 0.0, belowOverSpeed: 0.0)
        bottomBarView.backgroundColor = .lightGray
        topBarView.backgroundColor = .lightGray
    }
}

/*  print("Avg. speed: \(speed.avg*3.6)")
      print("Max. speed:\(speed.max*3.6)")
      print("acc\(acceleration.current):(current speed)\(speed.current)-(last speed)\(speed.last)")
      print("max acc:\(acceleration.max)")*/
