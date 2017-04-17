//
//  RainMessageViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import MessageUI

class RainMessageViewController: UIViewController {

    private var mailModel:MailModel?
    
    convenience init(mailModel:MailModel) {
        self.init()
        self.mailModel = mailModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "发送信息"
        self.setupView()
    }
    
    //这里可以自定义ui
    private func setupView(){
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.center = self.view.center
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.view.addSubview(button)
        button.setTitle("点击发送信息", for: UIControlState.normal)
        button.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
    }
    
    @objc
    private func sendMessage(){
        guard MFMessageComposeViewController.canSendText() else {
            print("不能发送短信")
            return
        }
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self // 代理
        messageVC.recipients = ["15900000000"] // 收件人
        messageVC.body = "短信内容" // 内容
        // 发送主题
        if MFMessageComposeViewController.canSendSubject() {
            messageVC.subject = "哈哈哈啊哈哈哈😀"
        }
        
        // 发送附件
        
        if MFMessageComposeViewController.canSendAttachments() {
            
            // 路径添加
            
            if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
                messageVC.addAttachmentURL(NSURL(fileURLWithPath: path) as URL, withAlternateFilename: "Info.plist")
            }
            
            // NSData添加
            
            if MFMessageComposeViewController.isSupportedAttachmentUTI("public.png") {
            
                if let image = UIImage(named: "qq") {
                    if let data = UIImagePNGRepresentation(image) {
                        // 添加文件
                        messageVC.addAttachmentData(data, typeIdentifier: "public.png", filename: "qq.png")
                    }
                    
                }
                
            }
            
        }
        
        // messageVC.disableUserAttachments() // 禁用添加附件按钮
        self.present(messageVC, animated: true, completion: nil)
    }
    
    deinit {
        print("message销毁")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension RainMessageViewController:MFMessageComposeViewControllerDelegate{
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // 关闭MFMessageComposeViewController
        controller.dismiss(animated: true, completion: nil)
        
        switch result { // 发送状态
        case .cancelled:
            print("Result: Mail sending cancelled") // 取消发送
        case .sent: // 发送成功
            print("Result: Mail sent")
        case .failed: // 发送失败
            print("Result: Message sending failed")
        }
        
    }
    
}
