//
//  HowItWorksPageViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 1/13/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// HOW IT WORKS PAGE VIEW (SLIDER)

import UIKit
import Material
import Firebase


class HowItWorksPageViewController: UIPageViewController {
    
    let loggedInUser = Auth.auth().currentUser
    var snapshot:NSDictionary? = nil
    // ColstoredView is How it works slides
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // if trainer statement return
        
        if (self.snapshot!["trainer"] as? Bool)!{
            return [self.newColoredViewController(color: "StepOneTrainer"),
                    self.newColoredViewController(color: "StepTwoTrainer"),
                    self.newColoredViewController(color: "StepThreeTrainer"),
                    self.newColoredViewController(color: "StepFourTrainer")]
        }
        
        return [self.newColoredViewController(color: "StepOne"),
                self.newColoredViewController(color: "StepTwo"),
                self.newColoredViewController(color: "StepThree")]
    }()
    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "HowItWorks", bundle: nil) .
            instantiateViewController(withIdentifier: "\(color)")
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        stylePageControl()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Menu Button
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
        }
        

    }
    // Slider dots
    private func stylePageControl() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf:[HowItWorksPageViewController.self])
        pageControl.currentPageIndicatorTintColor = Color.blue.lighten4
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = Color.grey.darken4
        
        
    }
    
}
// PAGE VIEW METHODS
extension HowItWorksPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}

