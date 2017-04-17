//
//  DemoViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    private var isF = true

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIView()
        vc.backgroundColor = UIColor.red
        vc.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        vc.layer.cornerRadius = 15
        vc.center = self.view.center
        self.view.addSubview(vc)
        self.view.backgroundColor = UIColor.white
        RainMotionManager.share.startMotion { (model) in
            if self.isF{
                self.isF = false
                let x = vc.frame.origin.x + CGFloat(model.moX*1.0)
                let y = vc.frame.origin.y - CGFloat(model.moY*1.0)
                print("\(x)=\(y)")
                vc.frame = CGRect(x: x, y: y, width: 30, height: 30)
                self.isF = true
            }
        }
    }
    
    deinit {
        RainMotionManager.share.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
