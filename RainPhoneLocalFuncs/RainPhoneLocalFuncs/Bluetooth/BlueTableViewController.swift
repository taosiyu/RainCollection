//
//  BlueTableViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/17.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueTableViewController: UITableViewController {
    
    let blue:BluetoothManager = BluetoothManager.init()
    
    let av = UIActivityIndicatorView.init()
    
    let titleVC:UIView = {
        let vc = UIView.init()
        vc.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        return vc
    }()
    
    fileprivate var blues = [CBPeripheral]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        blue.infoBackClosure = {[unowned self] (CBPS) in
            self.blues = CBPS
            self.tableView.reloadData()
        }
        
        av.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
        av.color = UIColor.black
        titleVC.addSubview(av)
        
        self.navigationItem.titleView = titleVC
        av.startAnimating()
        
        
        let btn = UIBarButtonItem.init(title: "stop", style: UIBarButtonItemStyle.done, target: self, action: #selector(changeBtnState(btn:)))
        self.navigationItem.rightBarButtonItem = btn

    }
    
    func changeBtnState(btn:UIBarButtonItem){
        if av.isAnimating {
            av.stopAnimating()
            btn.title = "start"
            self.blue.cancelPeripheralConnection()
        }else{
            av.startAnimating()
            btn.title = "stop"
            self.blue.startBlue()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.blues.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let cbp = self.blues[indexPath.row]
        cell.textLabel?.text = cbp.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let p = self.blues[indexPath.row]
        self.blue.lineCBP(CBPer: p)
    }
 


}
