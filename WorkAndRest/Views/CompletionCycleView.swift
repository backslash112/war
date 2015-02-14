//
//  CompletionCycleView.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/6.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit
import AVFoundation

protocol CompletionCycleViewDelegate {
    func completionCycleView(sender: CompletionCycleView, didSelectedNumber number: Int)
}

class CompletionCycleView: UIView {

    var delegate: CompletionCycleViewDelegate?
    
    var number = GlobalConstants.DEFAULT_NUMBER

    @IBOutlet var view: UIView!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var plusButton: UIButton!
    
    @IBAction func plusButtonClick(sender: AnyObject) {
        AudioServicesPlaySystemSound(1103)
        number++
        self.refreshView()
        self.delegate?.completionCycleView(self, didSelectedNumber: number)
    }
    
    @IBAction func minusButtonClick(sender: AnyObject) {
        AudioServicesPlaySystemSound(1103)
        number--
        self.refreshView()
        self.delegate?.completionCycleView(self, didSelectedNumber: number)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        self.refreshView()
    }
    

    func setup() {
        NSBundle.mainBundle().loadNibNamed("CompletionCycleView", owner: self, options: nil)
        self.addSubview(self.view)

        self.view.mas_updateConstraints { make in
            make.width.equalTo()(self.frame.size.width-40)
            make.height.equalTo()(self.frame.size.height)
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.mas_centerY)
            return ()
        }
    }
    
    func refreshView() {
        self.numberLabel.text = "\(number)"
        self.minusButton.enabled = number > 1
        self.plusButton.enabled = number < 250
    }
}
