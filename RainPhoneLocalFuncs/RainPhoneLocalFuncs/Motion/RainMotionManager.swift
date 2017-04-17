//
//  RainMotionManager.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import CoreMotion

private let timeNum = 1.0

//各种控制器的合集
class RainMotionManager: NSObject {
    
    //传感器控制器
    private var motionManager:CMMotionManager = {
        let mo = CMMotionManager.init()
        mo.accelerometerUpdateInterval = timeNum/30.0 //30帧
        mo.gyroUpdateInterval = 0.5                   //陀螺
        mo.magnetometerUpdateInterval = 0.5
        return mo
    }()
    
    static var share:RainMotionManager = {
        struct Static{
            static let instance:RainMotionManager = RainMotionManager()
        }
        return Static.instance
    }()
    
    private override init(){
        super.init()
    }
    
    //MARK:启动加速器
    func startMotion(dataClosure:@escaping ((motionModel)->())){
        if !self.motionManager.isAccelerometerAvailable{
            print("加速器不能使用")
        }
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
            let acceleration = accelerometerData?.acceleration
            if let acc = acceleration{
                let model = motionModel.init(acc)
                dataClosure(model)
            }
        }
    }
    
    //MARK:启动陀螺器
    func startGyro(dataClosure:@escaping ((motionModel)->())){
        if !self.motionManager.isGyroAvailable{
            print("陀螺不能使用")
        }
        self.motionManager.startGyroUpdates(to: OperationQueue.main) { (gyroData, error) in
            if let data = gyroData{
                let model = motionModel.init(data)
                dataClosure(model)
            }
        }
        
    }
    
    //MARK:启动磁力
    func startMagnetomete(dataClosure:@escaping ((motionModel)->())){
        if !self.motionManager.isMagnetometerAvailable{
            print("磁力不能使用")
        }
        self.motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (magnetometerData, error) in
            if let data = magnetometerData{
                let model = motionModel.init(data)
                dataClosure(model)
            }
        }
        
    }
    
    func stop(){
        //停止
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.stopGyroUpdates()
        self.motionManager.stopMagnetometerUpdates()
    }
}

//方便使用的model
struct motionModel {
    private(set) var moX:Double = 0
    private(set) var moY:Double  = 0
    private(set) var moZ:Double  = 0
    init(_ acceleration:CMAcceleration) {
        self.moX = acceleration.x
        self.moY = acceleration.y
        self.moZ = acceleration.z
    }
    init(_ gytoData:CMGyroData) {
        self.moX = gytoData.rotationRate.x
        self.moY = gytoData.rotationRate.y
        self.moZ = gytoData.rotationRate.z
    }
    init(_ magData:CMMagnetometerData) {
        self.moX = magData.magneticField.x
        self.moY = magData.magneticField.y
        self.moZ = magData.magneticField.z
    }
}
