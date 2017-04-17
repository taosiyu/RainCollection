//
//  ContactsTableViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    
    private var contactManager = ContactsManager.ShareManager //持有联系人控制对象
    
    private var sourceContacts = [ImportAddressBookModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "通讯录"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        contactManager.contactsGet(taskClosure: { (_) -> Bool in
            //taskClosure 顾名思义就是一个处理读取到的联系人的信息进行筛选，这里可以自定义，不用也是可以的
            return true
        }) {[unowned self] (source, _) in
            self.sourceContacts = source
            self.tableView.reloadData()
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
        return self.sourceContacts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

       cell.textLabel?.text = "\(self.sourceContacts[indexPath.row].name):\(self.sourceContacts[indexPath.row].phone.first!)"

        return cell
    }
 
}
