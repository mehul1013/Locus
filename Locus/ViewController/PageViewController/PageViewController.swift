//
//  PageViewController.swift
//  Locus
//
//  Created by Mehul Solanki on 23/08/17.
//  Copyright © 2017 Mehul Solanki. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CoreLocation

class PageViewController: UIPageViewController {
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(color: "First"),
                self.newColoredViewController(color: "Second"),
                self.newColoredViewController(color: "Third"),
                self.newColoredViewController(color: "Fourth")]
    }()
    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(color)")
    }
    
    var btnFacebook: UIButton!
    var pageControl: UIPageControl!
    
    // Track the current index
    var currentIndex: Int?
    var pendingIndex: Int?

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set Delegate
        delegate = self
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        //Create Facebook Button
        btnFacebook = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 44, width: self.view.frame.size.width, height: 44))
        btnFacebook.setTitle("Login with Facebook", for: .normal)
        btnFacebook.titleLabel?.font = UIFont(name: Constants.Fonts.Roboto_Medium, size: 17.0)
        btnFacebook.backgroundColor = Constants.COLOR_FACEBOOK
        btnFacebook.addTarget(self, action: #selector(btnFacebookClicked), for: .touchUpInside)
        self.view.addSubview(btnFacebook)
        
        //Create Page Control
        pageControl = UIPageControl(frame: CGRect(x: 0, y: self.view.frame.size.height - 75, width: self.view.frame.size.width, height: 31))
        pageControl.currentPage = 1
        pageControl.numberOfPages = 4
        self.view.addSubview(pageControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigation Bar
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Status Bar Visibility
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK: - Facebook
    func btnFacebookClicked() -> Void {
        print("Facebook clicked ...")
        
        //Dashboard
        //self.navigateToDashboard()
        //return
        
        
        
        //Check LOCATION permission
        guard isLocationPermissionEnabled() else {
            return
        }
        
        let login: FBSDKLoginManager! = FBSDKLoginManager()
        login.loginBehavior = .browser
        
        //let permissions = ["public_profile", "email"]
        let permissions = ["public_profile", "email", "user_birthday", "user_education_history", "user_friends", "user_hometown", "user_likes", "user_location", "user_work_history", "user_photos", "user_about_me"]
        
        login.logOut()
        login.logIn(withReadPermissions: permissions, from: self, handler: { (result, error) -> Void in
            
            if ((error) != nil) {
                print("Process error")
            } else if (result?.isCancelled)! {
                print("Cancelled")
            } else {
                print("Logged in")
                
                //Start Loading
                //AppUtils.startLoading(view: self.view)
                
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id,name,first_name,last_name,email,picture.type(large),birthday,about,education,gender,hometown,interested_in,work,likes.limit(1000),friends"])
                
                let connection = FBSDKGraphRequestConnection()
                connection.add(graphRequest, completionHandler: { (connection, result, error) in
                    
                    if error == nil {
                        print("User Info : \(result!)")
                        //self.callWebServiceToSaveUserData(dict: result as! [String:AnyObject])
                        
                        //Navigate to Dashboard
                        self.navigateToDashboard()
                    }else {
                        print("Error Getting Info \(error)");
                        
                        //Stop Loading
                        //AppUtils.stopLoading()
                    }
                })
                connection.start()
            }
        })
    }
    
    
    //MARK: - Navigate To Dashboard
    func navigateToDashboard() -> Void {
        let dashboardVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.StoryBoardIdentifier.storyDashboardVC) as! Dashboard
        
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    
    
    //MARK: - Location Permission Enable or not
    func isLocationPermissionEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //AppUtils.showAlertWithTitle(title: AlertMessages.NO_LOCATION_PERMISSION, message: AlertMessages.ENABLE_LOCATION, viewController: self)
                
                self.openSettingScreen()
                
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location : Access")
                return true
            }
        } else {
            AppUtils.showAlertWithTitle(title: AlertMessages.NO_LOCATION_PERMISSION, message: AlertMessages.ENABLE_LOCATION, viewController: self)
            return false
        }
    }
    
    func openSettingScreen() -> Void {
        let alert = UIAlertController(title: "" , message: AlertMessages.ENABLE_LOCATION, preferredStyle: .actionSheet)
        let actionLogout = UIAlertAction(title: "Open Setting", style: .default) {
            UIAlertAction in
            
            //Navigate To Setting Screen
            self.openSetting()
        }
        
        // Add the actions
        alert.addAction(actionLogout)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openSetting() -> Void {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}

//MARK: - UIPageViewController Data Source
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        pendingIndex = orderedViewControllers.index(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
}
