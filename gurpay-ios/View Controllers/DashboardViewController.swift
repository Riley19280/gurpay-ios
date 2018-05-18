//
//  DashboardViewController.swift
//  gurpay-ios
//
//  Created by Schoppa, Riley on 4/25/18.
//  Copyright © 2018 Rileystech. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var nameBarButton: UIBarButtonItem!
    @IBOutlet weak var bgView: UIView!

    @IBOutlet var boxViews: [UIView]!
    
    @IBOutlet weak var unpaidCountLabel: UILabel!
    @IBOutlet weak var unpaidBillLabel: UILabel!
    @IBOutlet weak var nextDueOnLabel: UILabel!
    @IBOutlet weak var recievedPeopleLabel: UILabel!
    @IBOutlet weak var paidOthersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       navigationController?.navigationBar.tintColor = UIColor.white
        
        Util.getUser(user_id: Util.getDeviceId(), success: {user in self.nameBarButton.title = user.name; }, error: { _ in self.nameBarButton.title = "You"; })
        
        ServiceBase.getGroup(
            success: {
                let group = Group.getFromDisk()!
                self.title = group.name;
            },
            error: {err in
                
            })
    }
    
    func loadData(){
        ServiceBase.getDashboard(
            success: { db in
                self.unpaidCountLabel.text = String(db.myUnpaidBillCount)
                if db.myUnpaidBillCount == 0 {
                    self.unpaidCountLabel.textColor = UIColor(red: 37/255, green: 213/255, blue: 0, alpha: 1)
                }
                if db.nextDueDate != nil {
                self.nextDueOnLabel.text = "Next bill due on \(Util.displayDate(date: db.nextDueDate)!)"
                }
                else {
                    self.nextDueOnLabel.alpha = 0;
                }
                self.recievedPeopleLabel.text = "You have recieved $\(db.myBillsPayerPaidToDate)/\(db.myBillsPayerPaidTotal) from \(db.myBillsPayersPaid)/\(db.myBillsPayerCount) people."
                
                self.paidOthersLabel.text = "You have paid $\(db.payTotalToDate)/\(db.payTotal) to others for \(db.payTotalCountToDate)/\(db.payTotalCount) bills."
                self.unpaidBillLabel.text = "unpaid bills."
            },
            error: { err in
               //self.boxLabels.forEach({$0.text = "Error"})
            })
    }
    
    override func viewDidLayoutSubviews() {
        let shadowPath = UIBezierPath(rect: bgView.bounds)
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = false
        bgView.layer.shadowRadius = 4
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowPath = shadowPath.cgPath
        
        boxViews.forEach({
            let shadowPath = UIBezierPath(rect: $0.bounds)
            $0.layer.cornerRadius = 5
            $0.layer.masksToBounds = false
            $0.layer.shadowRadius = 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowPath = shadowPath.cgPath
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
  
        
        loadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToArchive" {
            guard let billListTableViewController = segue.destination as? BillListTableViewController else { fatalError("Incorrect segue view controller.")}
            billListTableViewController.isArchive = true;
        }
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
