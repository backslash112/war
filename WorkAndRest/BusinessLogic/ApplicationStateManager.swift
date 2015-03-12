//
//  ApplicationStateManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/3/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

private let _singletonInstance = ApplicationStateManager()

class ApplicationStateManager: NSObject {

    let Probation: NSTimeInterval = 7
    class var sharedInstance: ApplicationStateManager {
        return _singletonInstance
    }

    func setup() {
        NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: GlobalConstants.k_FirstLauchDate)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func isExpired() -> Bool {
        let firstLaunchDate: NSDate = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_FirstLauchDate) as NSDate
        let timeInterval: NSTimeInterval = 60 * 60 * 24 * Probation * -1
        return NSDate(timeIntervalSinceNow: timeInterval).compare(firstLaunchDate) == NSComparisonResult.OrderedDescending
    }
}
