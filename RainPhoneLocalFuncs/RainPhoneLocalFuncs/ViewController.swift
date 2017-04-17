//
//  ViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let titles = ["本地邮件","本地短信","拨打电话","获取联系人（可以添加，自己改）","加速器","蓝牙","WKWebView","地图"]
    
    private var myTableView:UITableView = {
        let vc = UITableView()
        vc.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.myTableView)
        self.title = "手机本地功能"
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            var model = MailModel()
            model.toMail = "exmpl@cc.com"
            let vc = RainMailViewController.init(mailModel: model)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1:
            let vc = RainMessageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            RainPhone.doCallWithPhone(phone: "15900982800", inCtr: self)
            break
        case 3:
            let vc = ContactsTableViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let vc = DemoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 5:
            let vc = BlueTableViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 6:
            let vc = WKWebViewController.init(urlStr: "https://www.baidu.com", title: "baidu")
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 7:
            let vc = MapViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }


}

