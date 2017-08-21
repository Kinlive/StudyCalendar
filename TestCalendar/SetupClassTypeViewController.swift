//
//  SetupClassTypeViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

var beforeText : String?
var isOverCount = false

class SetupClassTypeViewController: UIViewController,UITextFieldDelegate {
    var classTypeArray = [String]()
    var indexPathOnEdit : IndexPath?
    let tfCoordinator = TextFieldCoordinator()
    var btnWidth : CGFloat?
    
    @IBOutlet weak var theCoverView: UIView!
    @IBOutlet weak var hideTheSaveBtn: UIButton!
    @IBOutlet weak var classTypeTableView: UITableView!
    @IBOutlet weak var showClassType: UILabel!
    
  
    @IBOutlet weak var startTimeKeyIn: UITextField!    
    @IBOutlet weak var workingHoursKeyIn: UITextField!
    
    @IBOutlet weak var overtimeKeyIn: UITextField!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//            self.preferredContentSize = CGSize(width: self.view.frame.width/3, height: self.view.frame.height/2)
            self.classTypeTableView.delegate = self
            self.classTypeTableView.dataSource = self
            startTimeKeyIn.delegate = self
            workingHoursKeyIn.delegate = self
            overtimeKeyIn.delegate = self
            for index in 0..<classTypeCDManager.count(){
                let item = classTypeCDManager.itemWithIndex(index: index)
                guard let typeName = item.typeName else {return }
                classTypeArray.append(typeName)
            }
           
            
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        animateShowVC()
    }
    
    func animateShowVC() {
        self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.size.height)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 1.5,
                                    delay: 0.05,
                                    usingSpringWithDamping: 0.8,
                                    initialSpringVelocity: 0,
                                    options: .transitionFlipFromTop  ,
                                animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.alpha = 1.0
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        animateDismissVC()
    }
    func animateDismissVC() {
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        self.view.alpha = 1.0
        UIView.animate(withDuration: 1.5,
                       delay: 0.05,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .transitionFlipFromTop  ,
                       animations: {
                        self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.size.height)
                        self.view.alpha = 0.0
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - TextField Delegate 
    func textFieldDidBeginEditing(_ textField: UITextField) {
         hideTheSaveBtn.isHidden = false
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        beforeText = string
//        return true
//    }
    
    
    func limitTextLength(textField : UITextField  ){
        isOverCount = false
        guard let text = textField.text else { return }
        
        switch textField.tag {
        case 16138:
            if text.characters.count > 10{
                textField.text = beforeText
                isOverCount = true
            }else {
                isOverCount = false
            }
            
        case 9527:
            if text.characters.count > 3{
                textField.text = beforeText
                isOverCount = true
            }else {
                isOverCount = false
            }
            
        default:
            break
        }
    }
    
    func createAlertView(){
        let alert = UIAlertController.init(title: nil,
                                                             message: "Please Key In ClassType",
                                                             preferredStyle: .alert)

        alert.addTextField { (classType) in
//            classType.delegate = self.tfCoordinator
            classType.placeholder = "Key in ClassType : name"
//            classType.tag = 16138
//            classType.addTarget(self, action: #selector(self.limitTextLength(textField:)), for: .editingChanged)
            
        }
        alert.addTextField { (startTime) in
            startTime.delegate = self.tfCoordinator
            startTime.placeholder = "Key in Start Time : 0730"
            startTime.tag = 9527
//            startTime.addTarget(self, action: #selector(self.limitTextLength(textField:)), for: .editingChanged)
            
        }
        alert.addTextField { (workingTime) in
            workingTime.placeholder = "Key in  Working Time : 8"
            
        }
        alert.addTextField { (overtime) in
            overtime.placeholder = "Key in overtime : 2"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            //SavaData to classType
            let item = classTypeCDManager.createItem()
            item.typeName = alert.textFields?[0].text
            item.startTime = alert.textFields?[1].text
            item.workingHours = alert.textFields?[2].text
            item.overtime = alert.textFields?[3].text
            classTypeCDManager.saveContexWithCompletion(completion: { (success) in
                if(success){
                    self.classTypeTableView.reloadData()
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    
    
    
    @IBAction func addClassType(_ sender: UIBarButtonItem) {
        createAlertView()
    }
    
    @IBAction func onEditSave(_ sender: UIButton) {
        guard let indexPathOnEdit = indexPathOnEdit else { return}
        let item = classTypeCDManager.itemWithIndex(index: indexPathOnEdit.row )
        item.typeName = showClassType.text
        item.startTime =  startTimeKeyIn.text
        item.workingHours = workingHoursKeyIn.text
        item.overtime = overtimeKeyIn.text
        classTypeCDManager.saveContexWithCompletion { (success) in
            if success {
                self.indexPathOnEdit = nil
                self.classTypeTableView.reloadData()
                sender.isHidden = true
            }
        }

        
        
    }

}//Class out here

extension SetupClassTypeViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..
        if classTypeCDManager.count() == 0{
            let displayLabel = UILabel(frame:
                CGRect( x: tableView.frame.width/4, y: 0,
                        width: tableView.frame.width/2,
                        height: tableView.frame.height))
            displayLabel.text = "Tap plus to add ClassType"
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
        return classTypeCDManager.count()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeTableViewCell", for: indexPath) as! ClassTypeTableViewCell
        let item = classTypeCDManager.itemWithIndex(index: indexPath.row)
        for i in 0..<classTypeArray.count{
            if item.typeName == classTypeArray[i]{
                cell.colorView.backgroundColor = UIColor(colorWithHexValue: colorArray[i]).withAlphaComponent(0.3)
            }
        }
        cell.layer.cornerRadius = cell.layer.frame.size.height/2
//        cell.layer.borderColor = UIColor.gray.cgColor
//        cell.layer.borderWidth = 2.0
        cell.classTypeName.text = item.typeName
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return tableView.frame.height/7
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        hideTheSaveBtn.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.theCoverView.backgroundColor = UIColor(colorWithHexValue: 0x97CBFF)
        }) { (finished) in
            if finished{
                UIView.animate(withDuration: 0.5, animations: {
                    //            self.theCoverView.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                    self.theCoverView.transform = CGAffineTransform(translationX: 0.0, y: self.view.frame.size.height)
                }) { (finish) in
                    if finish{
                        self.theCoverView.isHidden = true
                    }
                }
            }
        }
        
        indexPathOnEdit = indexPath
        let item = classTypeCDManager.itemWithIndex(index: indexPath.row)
        showClassType.text = item.typeName
        startTimeKeyIn.text = item.startTime
        workingHoursKeyIn.text = item.workingHours
        overtimeKeyIn.text = item.overtime
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = classTypeCDManager.itemWithIndex(index: indexPath.item)
            classTypeCDManager.deleteItem(item: item)
            classTypeCDManager.saveContexWithCompletion(completion: { (success) in
                if success {
                    self.classTypeTableView.reloadData()
                }
            })
        }
    }
}
