//
//  StatisticsViewController.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/20.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

class StatisticsViewController: BaseTableViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    @IBOutlet var rateSwitch: UISwitch!
    @IBOutlet var showPercentageSwitch: UISwitch!
    @IBOutlet var statisticsView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var chatType =  TimeSpanType.Month
    var chartView: JBBarChartView!
    var chartViewFooterView: UIView!
    var data = [CGFloat]()
    var baseData: [Int: Array<Work>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame: CGRect!
        
        switch WARDevice.getPhoneType() {
        case .iPhone4, .iPhone5:
            frame = CGRectMake(0, 0, 222, 157)
            break
            
        case .iPhone6, .iPhone6Plus:
            frame = CGRectMake(0, 0, 311, 157)
            break
            
        default:
            break
        }
        self.chartView = JBBarChartView(frame: frame)
        self.statisticsView.addSubview(self.chartView)
        
        self.chartView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.centerY.equalTo()(self.statisticsView.mas_centerY).offset()(-17)
            make.width.equalTo()(frame.size.width)
            make.height.equalTo()(frame.size.height)
            return ()
        }
        
        self.chartView.delegate = self
        self.chartView.dataSource = self
        self.chartView.minimumValue = 0.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeFooterViewFromTheStatisticsView()
    }
    
    func setStateToExpanded() {
        self.chartView.reloadData()
        self.chartView.setState(.Expanded, animated: true)
    }
    
    func setStateToCollapsed() {
        self.chartView.setState(.Collapsed, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loaDataSourceBySegmentedControlSelectedIndex(self.segmentedControl.selectedSegmentIndex)
        self.chartView.reloadData()
    }
    
    // MARK: - Events
    
    @IBAction func rateSwitchValueChanged(sender: AnyObject) {
        
    }
    
    @IBAction func showPercentageSwitchValueChanged(sender: AnyObject) {
    }
    
    @IBAction func segmentControlValueChanged(sender: AnyObject) {
        self.loaDataSourceBySegmentedControlSelectedIndex((sender as UISegmentedControl).selectedSegmentIndex)
    }
    
    // MARK: - Methods
    
    func loaDataSourceBySegmentedControlSelectedIndex(index: Int) {
        var type: TimeSpanType = .Week
        switch index {
        case 0:
            // Week
            type = .Week
            break
            
        case 1:
            // Month
            type = .Month
            break
            
        case 2:
            // Year
            type = .Year
            break
            
        default:
            break
        }
        self.loadDataSourceByType(type)
        self.addFooterViewToTheStatisticsView(type)
    }
    
    func loadDataSourceByType(type: TimeSpanType) {
        
        let allTasks = WorkManager.sharedInstance.selectWorksByTimeType(type)
        self.data.removeAll(keepCapacity: false)
        
        let dic = self.getWorksCountWithGroup(allTasks, byType: type)
        self.baseData = dic
        for index in 0...dic.count-1 {
            let works = dic[index]! as Array<Work>
//            if works.count == 0 {
//                continue
//            }
            var finishedCount = 0
            var stopedCount = 0
            for work in works {
                if work.isFinished {
                    finishedCount++
                } else {
                    stopedCount++
                }
            }
            self.data.insert(CGFloat(finishedCount), atIndex: 0)
            self.data.insert(CGFloat(stopedCount), atIndex: 1)
        }
        
        // 1. Remove the zero item from the top of the data source.
        while self.data.count >= 2 && (self.data[0] == 0 && self.data[1] == 0) {
            println("******************************* Remove ******************************")
            self.data.removeAtIndex(0)
            self.data.removeAtIndex(0)
        }

        while self.data.count < self.getNumberOfBarsByPhoneSize() {
            self.data.append(CGFloat(0))
        }
        self.setChatViewMaximumValue(maxElement(self.data))
        self.setStateToCollapsed()
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("setStateToExpanded"), userInfo: nil, repeats: false)
    }
    
    func getCapacity() -> Int {
        if WARDevice.getPhoneType() == .iPhone6 || WARDevice.getPhoneType() == .iPhone6Plus {
            return 3
        }
        return 2
    }
    
    func setChatViewMaximumValue(value: CGFloat) {
        if value > 20 {
            // 20 = 30 / 1.4858
            // If the value too large, then set the max height of the chat to the_max_number * 1.4858
            self.chartView.maximumValue = value * 1.4858
        } else {
            self.chartView.maximumValue = 30
        }
    }
    
    func getWorksCountWithGroup(list: Array<Work>, byType type: TimeSpanType) -> [Int: Array<Work>]{
        
        var dic = [Int: Array<Work>]()
        
        let startComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth | .CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond , fromDate: NSDate())
        
        let endComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth | .CalendarUnitWeekday | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond , fromDate: NSDate())
        
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 1
        endComponents.hour = 23
        endComponents.minute = 59
        startComponents.second = 59
        
        let capacity = self.getCapacity()
        
        switch type {
        case .Week:
            for i in 0...capacity {
                startComponents.day = startComponents.day - (i == 0 ? 0 : 1)
                endComponents.day = startComponents.day
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                var result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Month:
            startComponents.day = startComponents.day - startComponents.weekday + 1
            for i in 0...capacity {
                startComponents.day = startComponents.day - ((i == 0 ? 0 : 1) * 7)
                endComponents.day = startComponents.day + 6
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
            
        case .Year:
            startComponents.day = 1
            endComponents.day = 0
            for i in 0...capacity {
                startComponents.month = startComponents.month - (i == 0 ? 0 : 1)
                endComponents.month = startComponents.month + 1
                let startDate = NSCalendar.currentCalendar().dateFromComponents(startComponents)!
                let endDate = NSCalendar.currentCalendar().dateFromComponents(endComponents)!
                let result = self.filterWorks(list, byStartDate: startDate, andEndDate: endDate)
                dic[i] = result
            }
            break
        }
        return dic
    }
    
    func filterWorks(list: Array<Work>, byStartDate startDate: NSDate, andEndDate endDate: NSDate) -> Array<Work> {
        return list.filter { $0.workTime.compare(startDate) != NSComparisonResult.OrderedAscending && $0.workTime.compare(endDate) != NSComparisonResult.OrderedDescending }
    }
    
    func removeFooterViewFromTheStatisticsView() {
        if self.chartViewFooterView != nil && self.chartViewFooterView.superview != nil {
            self.chartViewFooterView.removeFromSuperview()
        }
    }
    
    func addFooterViewToTheStatisticsView(type: TimeSpanType) {
        let LABEL_WIDTH: CGFloat = 40
        let LABEL_HEIGHT: CGFloat = 25
        self.chartViewFooterView = UIView(frame: CGRectMake(0, 0, self.chartView.frame.width, LABEL_HEIGHT))
        
        let todayComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitWeekday, fromDate: NSDate())
        switch type {
        case .Week:
//            for i in 0...self.getCapacity() {
//                let tempLabel = UILabel()
//                components.weekday += (i == 0 ? 0 : 1)
//                println("\(components.weekday)")
//                tempLabel.text = self.getWeekDayStringByWeekDayNumber(components.weekday)
//                let capacity = self.getCapacity()
//                tempLabel.frame = CGRectMake(CGFloat(((Int(((chartViewFooterView.frame.width - LABEL_WIDTH) / CGFloat(capacity))) * i))), 0, LABEL_WIDTH, LABEL_HEIGHT)
//                tempLabel.textColor = UIColor.whiteColor()
//                tempLabel.font = UIFont.systemFontOfSize(12)
//                tempLabel.textAlignment = NSTextAlignment.Center
//                chartViewFooterView.addSubview(tempLabel)
//            }
            
//            var todayIndex = -1
//            for index in 0...self.baseData.count-1 {
//                let works = self.baseData[index]! as Array<Work>
//                if works.count > 0 {
//                    let workItemComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitWeekday, fromDate: works.first!.workTime)
//                    if workItemComponents.year == todayComponents.year &&
//                        workItemComponents.month == todayComponents.month &&
//                        workItemComponents.day == workItemComponents.day {
//                        // today
//                        todayIndex = index
//                    }
//                }
//            }
//            
//            // The user hasn't finished any works, so today
//            if todayIndex == -1 {
//                
//            }
            
//            var labelList = [Int]()
//            while todayIndex >= 0 {
//                
//                labelList.insert(todayIndex, atIndex: 0)
//                todayIndex--
//            }
            
//            println(labelList)
            
//            for i in 0...self.getCapacity() {
//                let tempLabel = UILabel()
//                todayComponents.weekday += (i == 0 ? 0 : 1)
//                println("\(todayComponents.weekday)")
//                tempLabel.text = self.getWeekDayStringByWeekDayNumber(todayComponents.weekday)
//                let capacity = self.getCapacity()
//                tempLabel.frame = CGRectMake(CGFloat(((Int(((chartViewFooterView.frame.width - LABEL_WIDTH) / CGFloat(capacity))) * i))), 0, LABEL_WIDTH, LABEL_HEIGHT)
//                tempLabel.textColor = UIColor.whiteColor()
//                tempLabel.font = UIFont.systemFontOfSize(12)
//                tempLabel.textAlignment = NSTextAlignment.Center
//                chartViewFooterView.addSubview(tempLabel)
//            }
//            
//            // 1. Remove the zero item from the top of the data source.
//            while self.data.count >= 2 && (self.data[0] == 0 && self.data[1] == 0) {
//                self.data.removeAtIndex(0)
//                self.data.removeAtIndex(0)
//            }
//            
//            while self.data.count < self.getNumberOfBarsByPhoneSize() {
//                self.data.append(CGFloat(0))
//            }
            
            
            var dates = [NSDate?]()
            for index in 0...self.baseData.count-1 {
                let works = self.baseData[index]! as Array<Work>
                //            if works.count == 0 {
                //                continue
                //            }
//                var finishedCount = 0
//                var stopedCount = 0
//                for work in works {
////                    if work.isFinished {
////                        finishedCount++
////                    } else {
////                        stopedCount++
////                    }
//                }
//                self.data.insert(CGFloat(finishedCount), atIndex: 0)
//                self.data.insert(CGFloat(stopedCount), atIndex: 1)
                dates.insert(works.first?.workTime, atIndex: 0)
                
                while dates.count >= 1 && dates.first == nil {
                    println("******************************* Remove ******************************")
                    dates.removeAtIndex(0)
                }
                
                while dates.count < self.getCapacity()+1  {
                    dates.append(nil)
                }
            }
            
            println("datas: \(dates)")
            break
            
        case .Month:
            break
            
        case .Year:
            break
            
        }
        self.statisticsView.addSubview(chartViewFooterView)
        chartViewFooterView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.statisticsView.mas_centerX)
            make.bottom.equalTo()(self.statisticsView.mas_bottom).offset()(-10)
            make.width.equalTo()(self.chartView.frame.width)
            make.height.equalTo()(LABEL_HEIGHT)
            return ()
        }
    }
    
    func getWeekDayStringByWeekDayNumber(weekDay: Int) -> String {
        switch weekDay {
            
        case 1:
            return "Sun"
            
        case 2:
            return "Mon"
            
        case 3:
            return "Tue"
            
        case 4:
            return "Wed"
            
        case 5:
            return "Thu"
            
        case 6:
            return "Fri"
        
        case 7:
            return "Sat"
            
        default:
            return self.getWeekDayStringByWeekDayNumber(weekDay - 7)
        }
    }
    
    func addPercentageLabelToTheChartView() {
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 15
        }
        return 0.01
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

    }
    
    // MARK: - JBBarChartViewDelegate
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(self.getNumberOfBarsByPhoneSize())
    }
    
    func getNumberOfBarsByPhoneSize() -> Int {
        switch WARDevice.getPhoneType() {
        case .iPhone4, .iPhone5:
            return 6
            
        case .iPhone6, .iPhone6Plus:
            return 8
            
        default:
            return 0
        }
    }
    
    // MARK: - JBBarChartViewDataSource
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return self.data[Int(index)]
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return index % 2 == 0 ?
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9) :
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
    }
    
    func barPaddingForBarChartView(barChartView: JBBarChartView!) -> CGFloat {
        return 10.0
    }
    
    func barGroupPaddingForBarChartView(barChatView: JBBarChartView!) -> CGFloat {
        return 50.0
    }
    
    func itemsCountInOneGroup() -> Int32 {
        return 2
    }
}
