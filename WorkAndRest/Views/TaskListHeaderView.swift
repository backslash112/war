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
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var secondsLabel: UILabel!
    
    var flag = false
    var delegate: TaskListHeaderViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        NSBundle.mainBundle().loadNibNamed("TaskListHeaderView", owner: self, options: nil)
        self.addSubview(self.view)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        self.view.mas_remakeConstraints { make in
            make.width.equalTo()(self.frame.size.width)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.mas_remakeConstraints { make in
            make.width.equalTo()(self.frame.size.width)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
        self.startView.frame = self.view.bounds
        self.timerView.frame = self.view.bounds
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
        self.delegate?.taskListHeaderViewStartNewTask(self)
    }
    
    func updateTime(minutes: String, seconds: String) {
        self.secondsLabel.text = seconds
        self.minutesLabel.text = minutes
    }
}
