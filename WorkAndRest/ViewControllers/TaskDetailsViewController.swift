//
//  TaskDetailsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/10.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class TaskDetailsViewController: BaseTableViewController, TaskRunnerDelegate, TaskItemBaseViewDelegate, TaskTitleViewControllerDelegate {
    
    var taskItem: Task!
    var taskRunner: TaskRunner!
    var taskManager = TaskManager.sharedInstance
    
    @IBOutlet var taskItemBaseView: TaskItemBaseView!
    
//    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameButton: UIButton!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    
    @IBOutlet var expectTimesLabel: UILabel!
    @IBOutlet var finishedTimesLabel: UILabel!
    
    @IBAction func changeNameButtonClick(sender: AnyObject) {
        self.performSegueWithIdentifier("EditTaskTitleSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskItemBaseView.delegate = self
        self.taskItemBaseView.isBreakButtonEnable = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("viewWillAppear - TaskDetailsViewController")
        self.taskRunner.delegate = self
        self.taskItemBaseView.refreshTitle(self.taskItem.title)
        
        if self.taskItem.completed {
            self.taskItemBaseView.refreshViewByState(.Completed, animation:false)
        } else {
            self.taskItemBaseView.refreshViewByState(.Normal, animation:false)
        }
        
        if self.taskRunner.state == .Running {
            if self.taskRunner.runningTaskID() == self.taskItem.taskId {
                // the running task is this task
                self.taskItemBaseView.refreshViewBySeconds(self.taskRunner.seconds)
                self.taskItemBaseView.refreshViewByState(.Running, animation:false)
            } else {
                // the running task is other task
                if !self.taskItem.completed {
                    self.taskItemBaseView.disableWithTaskState(TaskState.Normal, animation: false)
                }
            }
        }
        self.refreshUI()
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTaskTitleSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as TaskTitleViewController
            controller.delegate = self
            controller.copyTaskItem = self.taskItem
        }
    }
    
    func refreshUI() {
        self.nameButton.setTitle(self.taskItem.title, forState: UIControlState.Normal)
        self.detailLabel.text = "Task, \(self.taskItem.expect_times) times"
        self.lengthLabel.text = "\(self.taskItem.minutes) Minutes / Task"
        self.expectTimesLabel.text = "\(self.taskItem.break_times)"
        self.finishedTimesLabel.text = "\(self.taskItem.finished_times)"
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //        self.taskItemBaseView.updateViewsWidth()
    //    }
//    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            if WARDevice.getPhoneType() == PhoneType.iPhone4 {
//                return 80
//            } else if WARDevice.getPhoneType() == PhoneType.iPhone5 {
//                return 150
//            }else if WARDevice.getPhoneType() == PhoneType.iPhone6 {
//                return 160
//            } else if WARDevice.getPhoneType() == PhoneType.iPhone6Plus {
//                return 190
//            }
//        } else if indexPath.row == 4 {
//            if WARDevice.getPhoneType() == PhoneType.iPhone4 {
//                return 250
//            } else if WARDevice.getPhoneType() == PhoneType.iPhone5 {
//                return 260
//            } else {
//                return 274
//            }
//        }
//        return 35
//    }
//    
    // MARK: - TaskRunnerDelegate
    
    func started(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
        self.taskItemBaseView.refreshViewByState(.Running)
    }
    
    func completed(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.taskManager.completeOneTimer(self.taskItem)
        self.refreshUI()
    }

    func breaked(sender: TaskRunner!) {
        self.taskItemBaseView.refreshViewByState(.Normal)
        self.taskManager.breakOneTimer(self.taskRunner.taskItem)
    }
    
    func tick(sender: TaskRunner!) {
        println("TaskDetailsViewController: \(sender.seconds)")
        if self.taskItemBaseView  == nil {
            return
        }
        self.taskItemBaseView.refreshViewBySeconds(sender.seconds)
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        
        if self.taskItem.completed {
            // If the task is completed, then you can active it.
//            self.taskItem.completed = false
//            DBOperate.updateTask(self.taskItem)
            self.taskManager.activeTask(self.taskItem)
            
            // If some other task is running, you can't start the actived stask.
            if self.taskRunner.state == .Running {
                self.taskItemBaseView.disableWithTaskState(TaskState.Normal, animation: true)
            } else {
                self.taskItemBaseView.refreshViewByState(TaskState.Normal, animation: true)
            }
            return
        }
        
        // This is a normal task.
        
        // But perhaps some task is running, and the running task mebye just youself.
        if self.taskRunner.state == .Running {
            
            if self.taskRunner.runningTaskID() == self.taskItem.taskId {
                self.taskRunner.stop()
            } else {
                println("Some other task is running, you can do nothing")
            }
            return
        }
        
        // This is a normal task and this is no a running task, so start it now! setup the task and go!
        self.taskRunner.setupTaskItem(self.taskItem)
        if self.taskRunner.canStart() {
            self.taskRunner.start()
            self.taskManager.startTask(self.taskItem!)
        }
    }
    
    // MARK: - TaskTitleViewControllerDelegate

    func addTaskViewController(controller: TaskTitleViewController!, didFinishAddingTask item: Task!) {
        
    }
    
    func addTaskViewControllerDidCancel(controller: TaskTitleViewController!) {
        
    }
    
    func addTaskViewController(controller: TaskTitleViewController!, didFinishEditingTask item: Task!) {
        self.taskItem.title = item.title
        self.taskItemBaseView.refreshTitle(self.taskItem.title)
        self.nameButton.setTitle(self.taskItem.title, forState: UIControlState.Normal)
        self.taskManager.updateTask(self.taskItem)
    }
}
