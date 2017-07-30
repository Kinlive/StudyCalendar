//
//  SetupPersonViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit



class SetupPersonViewController: UIViewController {
    var personArray = [PersonData]()
    var calendarDataArray = [CalendarData]()
    //for index pass from didSelect cell to button use
    var personTmpIndex : IndexPath?
    
    var titleIndex : Int = 0
    
//MARK: - IBOutlet here
    @IBOutlet weak var showPersonDetail: UIView! //never use
   
    @IBOutlet weak var showDetailOfLabel: UILabel! //person name
    
    @IBOutlet weak var showHoursOfLabel: UILabel!
    
    @IBOutlet weak var SetupPersonTableView: UITableView!
    
    @IBOutlet weak var showDate: UILabel!{
        didSet{
            showDate.isUserInteractionEnabled = true
            showDate.isMultipleTouchEnabled = true
        }
        willSet{
            
        }
    }
    @IBOutlet weak var showClassPerMonth: UITextView!
  


    // test textFields?
    @IBOutlet weak var nameTextFieldStatus: UITextField!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SetupPersonTableView.delegate = self
        SetupPersonTableView.dataSource = self

        //nameTextField test
//        nameTextFieldStatus.isHidden = true
        showDetailOfLabel.isHidden = true
        showHoursOfLabel.isHidden = true
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                                                action: #selector(swipeGestureRecognizer(_:)))
        leftSwipe.direction = .left
        showDate.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                                                  action: #selector(swipeGestureRecognizer(_:)))
        rightSwipe.direction = .right
        showDate.addGestureRecognizer(rightSwipe)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        let currentMonth = formatter.string(from: Date())
        for i in 0..<months.count {
            if  months[i] == currentMonth{
               titleIndex = i
            }
        }
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        createAlertView()
        
    }
    
    //之後reset可考慮搬到Setting Page
    @IBAction func resetOverTimeBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "人員時數重置", message: "確認後將進行人員時數重置,請確認您當月份班別已安排完成?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default) { (isOK) in
            self.resetPersonHours()
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
  
    
    @IBAction func nextBtn(_ sender: UIButton) {
//        let item = personCDManager.itemWithIndex(index: (personTmpIndex?.item)!)
        
//        testShowMonth.text = item.yearAndMonth
        
        for item in personArray{
        print("year:",item.year!,"month:",item.month!,"yearAndMonth:",item.yearAndMonth!,"name:",item.name!,"overtime:",item.overtime)
        }
        
    
    }
    

    @IBAction func backBtn(_ sender: UIButton) {
        
    }
    //MARK: - Reset the person hours
    func resetPersonHours(){
        for index in 0..<personCDManager.count(){
            let item = personCDManager.itemWithIndex(index: index)
            item.overtime = BaseSetup.overHoursOfMonth
        }
        personCDManager.saveContexWithCompletion { (success) in
            if success {
                self.SetupPersonTableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
            }
        }
    }
    
    
    //MARK: - CreatAlert method
    func createAlertView(){
        let alert = UIAlertController.init(title: nil, message: "Please key in Name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
             
//            for year in years {   //考慮是否移除
//                for month in months{
                    let item = personCDManager.createItem()
                    item.systemBaseName = alert.textFields?[0].text
                    item.name = alert.textFields?[0].text
                    item.overtime = BaseSetup.overHoursOfMonth
            //以下三個尚未使用,日後安排移除
                    item.month = months[6]
                    item.year = years[0]
                    item.yearAndMonth = "\(years[0])\(months[6])"
                   
//                }
//            }
            personCDManager.saveContexWithCompletion(completion: { (success) in
                if(success){
//                    self.personArray.append(item)
                    self.SetupPersonTableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                }
            })
        }//ok action block here
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - GetCalendarData on Array
    func getCalendarDetailData(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        calendarDataArray.removeAll()
        for i in 0..<calendarCDManager.count(){
            let item = calendarCDManager.itemWithIndex(index: i)
//            guard let year = item.year else { return }
//            guard let month = item.month else {return}
            guard let personName = item.personName else {return }
//            let yearAndMonth = "\(year)\(month)"
            //yearAndMonth == formatter.string(from: Date()),
            if personName == showDetailOfLabel.text{ //Get All  selected person's class
                calendarDataArray.append(item)
            }
        }
        var contentAllClass = String()
        for i in calendarDataArray {
            guard let name = i.personName else { return}
            guard let date = i.date else {return }
            let oneClassShow = "name:\(name) Date: \(date )\n"
            contentAllClass.append(oneClassShow)
            print("Test look array name:\(name) Date: \(date )\n")
        }
        showClassPerMonth.text = contentAllClass
//        formatter.dateFormat = "MM"
        showDate.text = formatter.string(from: Date())
    }
    //MARK: - SwipeGesture
    func swipeGestureRecognizer(_ swipe : UISwipeGestureRecognizer){
        switch swipe.direction {
        case UISwipeGestureRecognizerDirection.left:
            titleIndex += 1
            if titleIndex > (months.count)-1 {
                titleIndex = 0
            }
            print("swipe Left now")
        case UISwipeGestureRecognizerDirection.right:
            titleIndex -= 1
            if titleIndex < 0  {
                titleIndex = months.count-1
            }
            print("<<<<swipe right now<<<")
        default:
            break
        }
        showDate.text = "2017\(months[titleIndex])"
        print("Date should be change")
    }

}
//MARK: - TableView Delegate & DataSource
extension SetupPersonViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if personCDManager.count() == 0{
            let displayLabel = UILabel(frame:
                                                            CGRect( x: tableView.frame.width/4, y: 0,
                                                                    width: tableView.frame.width/2,
                                                                    height: tableView.frame.height))
            displayLabel.text = "Tap plus to add person list"
            displayLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            displayLabel.textAlignment = .center
            displayLabel.numberOfLines = 4
            tableView.backgroundView = displayLabel
            tableView.separatorStyle = .none
        }else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .none
//            tableView.separatorColor = UIColor(colorWithHexValue: 0x3399ff)
        }
        return personCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetupPersonTableViewCell", for: indexPath) as! SetupPersonTableViewCell
        let item = personCDManager.itemWithIndex(index: indexPath.item)
         self.personArray.append(item)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.overtime)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        self.nameTextFieldStatus.isHidden = true
        self.showDetailOfLabel.isHidden = false
        self.showHoursOfLabel.isHidden = false
        
        self.showDetailOfLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.showHoursOfLabel.text = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
        personTmpIndex = indexPath
       
       //////========
        getCalendarDetailData()
        }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = personCDManager.itemWithIndex(index: indexPath.item)
            personCDManager.deleteItem(item: item)
            personCDManager.saveContexWithCompletion(completion: { (success) in
                if success {
                    self.SetupPersonTableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAllCell"), object: nil)
                }
            })
        }
    }
    
}
