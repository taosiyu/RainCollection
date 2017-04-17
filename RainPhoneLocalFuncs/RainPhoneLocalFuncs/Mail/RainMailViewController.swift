//
//  RainMailViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import MessageUI

//邮件
class RainMailViewController: UIViewController {
    
    private let composeVC:MFMailComposeViewController = {
        let vc = MFMailComposeViewController()
        return vc
    }()
    
    private var mailModel:MailModel?
    
    convenience init(mailModel:MailModel) {
        self.init()
        self.mailModel = mailModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        composeVC.mailComposeDelegate = self
        self.title = "发送邮件"
        self.setupView()
    }
    
    //MARK:这里可以自定义ui
    private func setupView(){
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.center = self.view.center
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.view.addSubview(button)
        button.setTitle("点击发送邮件", for: UIControlState.normal)
        button.addTarget(self, action: #selector(sendMail), for: UIControlEvents.touchUpInside)
    }
    
    //发起邮件发送
    @objc
    private func sendMail(){
        if MFMailComposeViewController.canSendMail(), let model = self.mailModel {
            
            composeVC.setToRecipients([model.toMail])
            composeVC.setCcRecipients([model.toCcMail])
            composeVC.setBccRecipients([model.toBccMail])
            composeVC.setSubject(model.subject)
            composeVC.setMessageBody("<h1 style=\"color:red\">测试代码</h1>", isHTML: true)
            //附件
            if true {
                if let data = NSData.init(contentsOfFile: "") {
                    // 添加文件
                    composeVC.addAttachmentData(data as Data, mimeType: "data", fileName: model.fileName)
                }
            }
            
            present(composeVC, animated: true, completion: nil)
        }else{
            let vc = UIAlertController.init(title: "发邮件", message: "邮箱没有设置是无法发送的哦", preferredStyle: UIAlertControllerStyle.alert)
            let alert = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (_) in
                print("不能发送")
            })
            vc.addAction(alert)
            vc.show(self, sender: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RainMailViewController:MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        
        guard error == nil else { // 错误拦截
            return
        }
        
        switch result { // 发送状态
        case .cancelled:
            print("Result: Mail sending canceled") // 删除草稿
        case .saved: // 存储草稿
            print("Result: Mail saved")
        case .sent: // 发送成功
            print("Result: Mail sent")
        case .failed: // 发送失败
            print("Result: Mail sending failed")
        }
    }
}

struct MailModel {
    var toMail:String = ""
    var toCcMail:String = ""
    var toBccMail:String = ""
    var subject = "来自大洋彼岸的Mail"
    var messageBody = "body"
    var filePath = ""
    var fileName = "附件"
}
