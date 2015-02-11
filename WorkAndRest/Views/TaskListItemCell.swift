//
//  TaskListItemCell.swift
//  WorkAndRest
//
//  Created by YangCun on 15/1/30.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

protocol TaskListItemCellDelegate {
    func readyToStart(sender: TaskListItemCell!)
    func tick(timeString: String)
    func completed(sender: TaskListItemCell!)
    func breaked(sender: TaskListItemCell!)
    func activated(sender: TaskListItemCell!)
}

class TaskListItemCell: UITableViewCell, TaskRunnerDelegate, TaskItemBaseViewDelegate {
    
    @IBOutlet var tempView: UIView!
    @IBOutlet var taskItemBaseView: TaskItemBaseView!
//    @IBOutlet var titleLabel: UILabel!
    //@IBOutlet var bgImageView: UIImageView!
//    @IBOutlet var startButton: UIButton!
//    @IBOutlet var timerLabel: UILabel!
    //@IBOutlet var grayMaskView: UIView!
    @IBOutlet var pointImageView: UIImageView!
    
    var ANIMATION_DURATION = 0.5
    var seconds = 0
    var taskItem: Task?
    var taskRunner: TaskRunner?
    var delegate: TaskListItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
        println("awakeFromNib tempView w:\(self.tempView.frame.size.width)")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func startButtonClicked(sender: AnyObject) {
        
        if self.taskRunner != nil && self.taskRunner!.isWorking {
            self.breakIt()
        } else {
            if self.taskItem!.completed {
                self.taskItem!.completed = false
                if DBOperate.updateTask(self.taskItem!) {
                    self.delegate?.activated(self)
                }
            } else {
                self.delegate?.readyToStart(self)
            }
        }
    }
    
    func refresh() {
        self.taskItemBaseView.titleLabel.text = taskItem?.title
    }
    
    override func updateConstraints() {
        println("updateConstraints tempView w:\(self.tempView.frame.size.width)")
        super.updateConstraints()
    }
    
    func setup() {
        self.taskItemBaseView.delegate = self
        self.taskItemBaseView.timerLabel.alpha = 0
    }
    
    func start() {
        println("start tempView w:\(self.tempView.frame.size.width)")
        
        if !self.taskRunner!.canStart() {
            return
        }
        
        self.seconds = self.taskItem!.minutes * 60
        
        taskRunner?.start()
        self.taskItemBaseView.timerLabel.text = self.getTimerString()
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
                self.taskItemBaseView.startButton.alpha = 0
                self.taskItemBaseView.timerLabel.alpha = 1
            })
            { (finished: Bool) -> Void in
                self.changeToBreakButtonAfter2Seconds()
        }
        
        UIView.transitionWithView(self.taskItemBaseView.bgImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.taskItemBaseView.bgImageView.image = UIImage(named: "list_item_working_bg")
            }, completion: nil)
        
        
        UIView.transitionWithView(self.pointImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.pointImageView.image = UIImage(named: "point_green")
            }, completion: nil)
    }
    
    func breakIt() {
        self.taskRunner!.stop()
    }
    
    func disable() {
        self.reset()
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
                self.taskItemBaseView.startButton.alpha = 0.5
            })
    }
    
    func reset() {
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
                self.taskItemBaseView.timerLabel.alpha = 0
                self.taskItemBaseView.startButton.alpha = 1
        })
        
        UIView.transitionWithView(self.taskItemBaseView.bgImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.taskItemBaseView.bgImageView.image = UIImage(named: "list_item_finished_bg")
                } else {
                    self.taskItemBaseView.bgImageView.image = UIImage(named: "list_item_normal_bg")
                }
            }, completion: nil)
        
        
        UIView.transitionWithView(self.taskItemBaseView.startButton,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                } else {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }
            }, completion: nil)
        
        UIView.transitionWithView(self.pointImageView,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.pointImageView.image = UIImage(named: "point_gray")
                } else {
                    self.pointImageView.image = UIImage(named: "point_yellow")
                }
            }, completion: nil)
    }
    
    func changeImageWithAnimations(view: UIView, duration: NSTimeInterval) {
        UIView.transitionWithView(self.taskItemBaseView.startButton,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                if self.taskItem!.completed {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "redo"), forState: UIControlState.Normal)
                } else {
                    self.taskItemBaseView.startButton.setImage(UIImage(named: "start"), forState: UIControlState.Normal)
                }
            }, completion: nil)
        
        UIView.transitionWithView(view, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            
            }, completion: nil)
        
    }
    
    func getTimerString() -> String {
        return String(format: "%02d:%02d", arguments: [self.seconds % 3600 / 60, self.seconds % 3600 % 60])
    }
    
    // MARK: - TaskRunnerDelegate
    
    func tick(sender: TaskRunner?) {
        //println("tick: " + "\(sender?.taskItem.title)" + "\(sender!.seconds)")
        println("TaskListItemCell - tick")
        self.seconds = sender!.seconds
        let result = self.getTimerString()
        self.taskItemBaseView.timerLabel.text = result
        self.delegate?.tick(result)
    }
    
    func completed(sender: TaskRunner?) {
        println("completed")
        AudioServicesPlaySystemSound(1005)
        self.delegate?.completed(self)
        self.reset()
    }
    
    func breaked(sender: TaskRunner?) {
        self.delegate!.breaked(self)
    }
    
    func changeToBreakButtonAfter2Seconds() {
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("switchToBreakButton:"), userInfo: nil, repeats: false)
    }
    
    func switchToBreakButton(sender: NSTimer!) {
        UIView.animateWithDuration(ANIMATION_DURATION,
            animations: { () -> Void in
                self.taskItemBaseView.timerLabel.alpha = 0
                self.taskItemBaseView.startButton.alpha = 1
            })
            { (finished: Bool) -> Void in
        }
        UIView.transitionWithView(self.taskItemBaseView.startButton,
            duration: ANIMATION_DURATION,
            options: .TransitionCrossDissolve,
            animations: { () -> Void in
                self.taskItemBaseView.startButton.setImage(UIImage(named: "break"), forState: UIControlState.Normal)
            })
            { (finished: Bool) -> Void in
        }
    }
    
    // MARK: - TaskItemBaseViewDelegate
    
    func taskItemBaseView(view: UIView!, buttonClicked sender: UIButton!) {
        if self.taskRunner != nil && self.taskRunner!.isWorking {
            self.breakIt()
        } else {
            if self.taskItem!.completed {
                self.taskItem!.completed = false
                if DBOperate.updateTask(self.taskItem!) {
                    self.delegate?.activated(self)
                }
            } else {
                self.delegate?.readyToStart(self)
            }
        }
    }
    
    override func layoutSubviews() {
        println("layoutSubviews tempView - w:\(self.tempView.frame.size.width)")
        self.taskItemBaseView.updateViewsWidth()
        super.layoutSubviews()
    }
}
