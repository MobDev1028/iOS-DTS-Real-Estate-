//
//  AppDelegate.swift
//  DTS-iOS
//
//  Created by Andy Nyberg on 03/04/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreLocation
import GoogleMaps
import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let GOOGLE_MAP_KEY = "AIzaSyCtUEVMmGY37NtZYafPkgFrvXa3fkxAuLY"

    var btnSkip: UIButton!
    var window: UIWindow?
    var cachedImages: NSMutableDictionary!
    var likedProperies: NSMutableDictionary!
    var showAnimation: Bool!
    var isFromSignUp: Bool!
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var totalRows: NSInteger!
    var isBack: Bool!
    var selectedParent = -1
    var selectedIndex = -1
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var userProperty: NSMutableDictionary!
    var uclTitle: String!
    var isNewProperty: Bool?
    var newlyCreatedPropertyId: Int!
    var propertyPhotos: NSArray?
    var arrSearchCriteria: NSMutableArray!
    var presentedRow = -1
    var selectedSearchRegion: String?
    var selectedCoordinates: CLLocationCoordinate2D?
    var isAppLoading = true
    var properties = NSMutableArray()
    var isSearchPull = false
    var currentAddress: String?
//    var updateLocatoinFired = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        isBack = false
        self.selectedSearchRegion = ""
        
        
        
        self.selectedCoordinates = CLLocationCoordinate2DMake(40.774777, -73.956332)
        
//        switch CLLocationManager.authorizationStatus() {
//        case .AuthorizedAlways, .AuthorizedWhenInUse:
//            locationManager.delegate = self
//            locationManager.startUpdatingLocation()
//        case .NotDetermined:
//            locationManager.delegate = self
//            locationManager.requestWhenInUseAuthorization()
//        case .Denied:
//            print("Show Alert with link to settings")
//        case .Restricted:
//            // Nothing you can do, app cannot use location services
//            break
//        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = 100.0
        
        if self.locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) == true {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        
        self.totalRows = 0
        self.cachedImages = NSMutableDictionary()
        self.likedProperies = NSMutableDictionary()
        self.showAnimation = true
        self.isFromSignUp = false
        if NSUserDefaults.standardUserDefaults().objectForKey("token") != nil {
            self.UpdateRootVC()
        }
        else {
            let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainChildNav") as! UINavigationController
            AppDelegate.returnAppDelegate().window?.rootViewController = navVC
        }
        
//        do {
//            try playVideo()
//        } catch AppError.InvalidResource(let name, let type) {
//            debugPrint("Could not find resource \(name).\(type)")
//        } catch {
//            debugPrint("Generic error")
//        }
        GMSServices.provideAPIKey(GOOGLE_MAP_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_MAP_KEY)
        return true
    }
    
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("dts-splash", ofType:"mp4") else {
            throw AppError.InvalidResource("dts-splash", "mp4")
        }
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        playerController = AVPlayerViewController()
        playerController!.player = player
        //self.window?.rootViewController!.addChildViewController(playerController!)
        playerController!.view.frame = (self.window?.rootViewController!.view.bounds)!
        playerController!.showsPlaybackControls = false
        btnSkip = UIButton(type: .Custom)
        btnSkip.backgroundColor = UIColor.clearColor()
        btnSkip.setTitle("", forState: .Normal)
        btnSkip.frame = (self.window?.rootViewController?.view.frame)!
        btnSkip.addTarget(self, action: #selector(AppDelegate.skipVidoe), forControlEvents: .TouchUpInside)
        self.window?.rootViewController!.view.addSubview(playerController!.view)
        self.window?.rootViewController!.view.addSubview(btnSkip)
        
        player!.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
    }
    
    func skipVidoe() -> Void {
        btnSkip.removeFromSuperview()
        player?.pause()
        playerController?.view.removeFromSuperview()
        playerController?.removeFromParentViewController()
        NSNotificationCenter.defaultCenter().postNotificationName("PlayerStopped", object: nil, userInfo: nil)
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        btnSkip.removeFromSuperview()
        playerController?.view.removeFromSuperview()
        playerController?.removeFromParentViewController()
        NSNotificationCenter.defaultCenter().postNotificationName("PlayerStopped", object: nil, userInfo: nil)
    }
    
    enum AppError : ErrorType {
        case InvalidResource(String, String)
    }
    
    func logOut() -> Void {
        //navVC
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainChildNav") as! UINavigationController
        AppDelegate.returnAppDelegate().window?.rootViewController = navVC
    }
    
    func UpdateRootVC() -> Void {
        let tabbarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("tabbarVC") as! UITabBarController
        AppDelegate.returnAppDelegate().window?.rootViewController = tabbarVC

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    class func returnAppDelegate() ->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0]
    
        
        if NSUserDefaults.standardUserDefaults().boolForKey("updateLocatoinFired") == false {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "updateLocatoinFired")
            NSNotificationCenter.defaultCenter().postNotificationName("updateLocationFired", object: self.currentLocation)
        }
    }
}

