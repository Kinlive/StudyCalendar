//
//  SetupClassTypeViewController.swift
//  TestCalendar
//
//  Created by Kinlive on 2017/7/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

import UIKit

class SetupClassTypeViewController: UIViewController {
    var classTypeArray = [String]()
    

    @IBOutlet weak var classTypeTableView: UITableView!
    @IBOutlet weak var showClassType: UILabel!
    
    @IBOutlet weak var ruleOneTextField: UITextField!
    
    @IBOutlet weak var ruleTwoTextField: UITextField!
    
    @IBOutlet weak var ruleThreeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 800, height: 600)
        // Do any additional setup after loading the view.
        self.classTypeTableView.delegate = self
        self.classTypeTableView.dataSource = self
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlertView(){
        let alert = UIAlertController.init(title: nil, message: "Please Key In ClassType", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            //         self.personName = alert.textFields?[0].text
            self.classTypeArray.append((alert.textFields?[0].text)!)
            self.classTypeTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func addClassType(_ sender: UIBarButtonItem) {
        createAlertView()
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SetupClassTypeViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        //..
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //..
        return classTypeArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //..
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTypeTableViewCell", for: indexPath) as! ClassTypeTableViewCell
        cell.textLabel?.text = classTypeArray[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //..
        showClassType.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
    }
}
