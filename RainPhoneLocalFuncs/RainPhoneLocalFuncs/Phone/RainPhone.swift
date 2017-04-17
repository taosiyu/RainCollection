//
//  RainPhone.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import CoreTelephony

class RainPhone: NSObject {
    
    static func hasCellularCoverage() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let info = networkInfo.subscriberCellularProvider else {return false}
        
        guard let carrier = info.isoCountryCode else {
            print("No sim present Or No cellular coverage or phone is on airplane mode");
            return false
        }
        
        print("Carrier = \(carrier)");
        return true
    }
    
    
    
    static func doCallWithPhone(phone: String, inCtr: UIViewController) {
        let url = NSURL.init(string: "tel:\(phone.replacedSpaceString)")
        let application = UIApplication.shared
        
        if let validUrl = url {
            var title: String!
            let canMakeCall = application.canOpenURL(validUrl as URL) && RainPhone.hasCellularCoverage()
            if canMakeCall {
                title = phone
            } else {
                title = "无法拨打电话"
            }
            
            let alert = UIAlertController.init(title: title, message: phone, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            if canMakeCall {

                let callAction = UIAlertAction.init(title: "呼叫", style: UIAlertActionStyle.default, handler: { (_) in
                    application.openURL(validUrl as URL)
                })
                alert.addAction(callAction)
            }
            
            inCtr.present(alert, animated: true, completion: nil)
        }
    }

}

extension String{
    var replacedSpaceString: String {
        return (self as NSString).replacingOccurrences(of: " ", with: "")
    }
}




