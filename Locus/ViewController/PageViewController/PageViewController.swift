//
//  PageViewController.swift
//  Locus
//
//  Created by Mehul Solanki on 23/08/17.
//  Copyright © 2017 Mehul Solanki. All rights reserved.
//

import UIKit

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

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK: - Facebook
    func btnFacebookClicked() -> Void {
        print("Facebook clicked ...")
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
