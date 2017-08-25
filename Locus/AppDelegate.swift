//
//  AppDelegate.swift
//  Locus
//
//  Created by Mehul Solanki on 08/08/17.
//  Copyright © 2017 Mehul Solanki. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var strDeviceToken  : String?
    var locationManager : CLLocationManager!
    var strLat          : String! = "0"
    var strLong         : String! = "0"
    var completionBlock : (CLLocationCoordinate2D) -> Void = {_ in }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //Location Manager
        self.initializeLocationManager()
        
        //Facebook configuration
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Facebook Initialization
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    //MARK: - Facebook
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let parsedURL = BFURL(inboundURL: url, sourceApplication: sourceApplication)
        if ((parsedURL?.appLinkData) != nil) {
            // this is an applink url, handle it here
            let targetUrl = parsedURL?.targetURL
            
            let viewCTR = self.getCurrentViewController()
            AppUtils.showAlertWithTitle(title: "Received link:", message: (targetUrl?.absoluteString)!, viewController: viewCTR)
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //Get Current View Controller
    func getCurrentViewController() -> UIViewController {
        //let vc = self.window?.rootViewController
        let navCTR = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        let vc = navCTR.visibleViewController
        return vc!
    }
    

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Locus")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    //MARK: - Location Manager: - Get Current Location
    func initializeLocationManager() {
        
        locationManager = CLLocationManager()
        
        locationManager.delegate        = self
        locationManager.distanceFilter  = 50
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // Specify the type of activity your app is currently performing
        locationManager.activityType    = .otherNavigation
        
        // Enable background location updates
        //        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func getCurrentLocation(onCompletion:@escaping (CLLocationCoordinate2D) -> Void) {
        
        completionBlock = onCompletion
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined:
                print("Not Determined")
            case .restricted, .denied:
                print("Not Determined")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        strLat  = "0"
        strLong = "0"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let locValue:CLLocationCoordinate2D = manager.location?.coordinate {
            strLat  = getStringFromAnyObject(locValue.latitude as AnyObject)
            strLong = getStringFromAnyObject(locValue.longitude as AnyObject)
        }else {
            print("\n\nERROR == >> locations\n\n ")
        }
        
        locationManager.stopUpdatingLocation()
    }

}

