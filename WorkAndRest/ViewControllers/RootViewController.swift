//
//  RootViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/27.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "title"))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "white"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = false
        
        
        let helpButton = UIButton(frame: CGRectMake(0, 0, 36, 17))
        helpButton.setImage(UIImage(named: "help"), forState: UIControlState.Normal)
        helpButton.setImage(UIImage(named: "help"), forState: UIControlState.Highlighted)
        helpButton.addTarget(self, action: Selector("rightBarButtonClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        //self.tabBarController!.delegate = self
        self.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rightBarButtonClick(sender: UIButton!) {
        self.performSegueWithIdentifier("helpSegue", sender: nil)
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let fromView = tabBarController.selectedViewController?.view
        let toView = viewController.view
        
        if fromView == toView {
            return false
        }
        let fromIndex = find(tabBarController.viewControllers! as Array, tabBarController.selectedViewController!)
        let toIndex = find(tabBarController.viewControllers! as Array, viewController)
        
        UIView.transitionFromView(fromView!,
            toView: toView,
            duration: 0.1,
            options: UIViewAnimationOptions.TransitionCrossDissolve)
            { (finished) -> Void in
                if finished {
                    tabBarController.selectedIndex = toIndex!
                }
        }
        return true
    }
    
}