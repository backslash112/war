//
//  ItemDetailViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol ItemDetailViewControllerDelegate {
    func addTaskViewController(controller: ItemDetailViewController!, didFinishAddingTask item: Task!)
    func addTaskViewController(controller: ItemDetailViewController!, didFinishEditingTask item: Task!)
    func addTaskViewControllerDidCancel(controller: ItemDetailViewController!)
}

class ItemDetailViewController: BaseTableViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    var delegate: ItemDetailViewControllerDelegate! = nil
    @IBOutlet var textField: UITextField!
    var itemToEdit: Task!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.itemToEdit != nil {
            self.title = NSLocalizedString("Edit Task", comment: "")
            self.textField.text = itemToEdit!.title
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.textField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Events
    
    @IBAction func cancel(sender: AnyObject?) {
        if (self.delegate != nil) {
            self.delegate.addTaskViewControllerDidCancel(self)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func done(sender: AnyObject) {
        if itemToEdit == nil {
            let newItem = Task()
            newItem.title = self.textField.text
            self.delegate.addTaskViewController(self, didFinishAddingTask: newItem)
        } else {
            if itemToEdit.title == self.textField.text {
                self.cancel(nil)
                return;
            }
            itemToEdit!.title = self.textField.text
            self.delegate.addTaskViewController(self, didFinishEditingTask: itemToEdit)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 24.0
        }
        return 14.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.done(textField)
        return true
    }

}
