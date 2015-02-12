//
//  TaskListHeaderView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/8.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

protocol TaskListHeaderViewDelegate {
    func taskListHeaderViewStartNewTask(sender: TaskListHeaderView)
}

class TaskListHeaderView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var startView: UIView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var startButton: UIView!
//    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var secondsLabel: UILabel!
    
    var flag = false
    var delegate: TaskListHeaderViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskListHeaderView", owner: self, options: nil)
        //self.startView = self.initStartView()
        //self.timerView = self.initTimerView()
        
        self.addSubview(self.view)
        self.view.mas_updateConstraints { make in
            make.width.equalTo()(self.frame.size.width)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("tap:"))
        self.timerView.addGestureRecognizer(tap)
    }
    
    func tap(sender: UITapGestureRecognizer) {
        println("tap")
        //self.flip()
    }
    
    func flip() {
        println("flip")
        if !flag {
            UIView.transitionFromView(startView, toView: timerView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: nil)
        } else {
            UIView.transitionFromView(timerView, toView: startView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: nil)
        }
    }
    
    func flipToTimerViewSide() {
        flag = false
        self.flip()
    }
    
    func flipToStartViewSide() {
        flag = true
        self.flip()
    }
    
    func isInTimersViewSide() -> Bool {
        return flag == false
    }
    
    @IBAction func newTaskButtonClick(sender: UIButton) {
        println("newTaskButtonClick")
        //self.flip()
        self.delegate?.taskListHeaderViewStartNewTask(self)
    }
    
    func updateTime(minutes: String, seconds: String) {
        self.secondsLabel.text = seconds
        self.minutesLabel.text = minutes
    }
}
