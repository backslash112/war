//
//  SettingsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/16.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import MessageUI

let SubTitleSectionHeight: CGFloat = 50
class SettingsViewController: BaseTableViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var badgeAppIconSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.badgeAppIconSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_BADGEAPPICON)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func badgeAppIconSwitchValueChanged(sender: AnyObject) {
        let isShowBadgeAppIcon = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setBool(isShowBadgeAppIcon, forKey: GlobalConstants.kBOOL_BADGEAPPICON)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: - Navigation

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        if section == 1 || section == 3 {
            return SubTitleSectionHeight
        }
        return 15
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if section != 1 && section != 3 {
            return nil
        }
        
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, SubTitleSectionHeight))
        view.backgroundColor = UIColor.clearColor()
        let label = UILabel(frame: CGRectMake(16, -3, view.frame.size.width - 32, SubTitleSectionHeight))
        label.numberOfLines = 2
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        
        if section == 1 {
            label.text = "Show incomplete task count badge on the app icon."
        }
        if section == 3 {
            label.text = "The free version balabalabala....."
        }
        
        label.sizeToFit()
        view.addSubview(label)
        return view
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if indexPath.section == 1 && indexPath.row == 0 {
            // about
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            // rate
            UIApplication.sharedApplication().openURL(NSURL(string: GlobalConstants.APPSTORE_URL)!)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            // go premium
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            self.showSendEmailAlert()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    // MARK: - AlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if MFMailComposeViewController.canSendMail() {
                var mailComposeViewController = MFMailComposeViewController()
                mailComposeViewController.mailComposeDelegate = self
                mailComposeViewController.setToRecipients([GlobalConstants.EMAIL_ADDRESS])
                mailComposeViewController.setSubject(NSLocalizedString("Suggestions", comment: ""))
                mailComposeViewController.setMessageBody("", isHTML: false)
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultSent.value:
            self.showThanksAlert()
            break
            
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSendEmailAlert() {
        let alert = UIAlertView(title: NSLocalizedString("Send an email to the developers?", comment: ""),
            message: NSLocalizedString("Send email message", comment: ""),
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
            otherButtonTitles: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
    
    func showThanksAlert() {
        let alert = UIAlertView(title: "",
            message: NSLocalizedString("Thanks for your help", comment: ""),
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Yes", comment: ""))
        alert.show()
    }
}
