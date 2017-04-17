//
//  BluetoothManager.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/14.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject {
    
    fileprivate var blueManager:CBCentralManager!
    
    fileprivate var peripheral:CBPeripheral?
    
    fileprivate var characteristic:CBCharacteristic?
    
    fileprivate var services:[CBService] = [CBService]()
    
    fileprivate var blueSystems:[CBPeripheral] = [CBPeripheral]()
    
    //各种数据回调
    var infoBackClosure:(([CBPeripheral])->())?
    
//    var share:BluetoothManager = {
//        struct Static{
//            static let instance:BluetoothManager = BluetoothManager()
//        }
//        return Static.instance
//    }()
    
    override init() {
        super.init()
        blueManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    deinit {
        print("blue deinit")
        self.cancelPeripheralConnection()
    }
    
    func startBlue(){
        self.blueManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func lineCBP(CBPer:CBPeripheral){
        self.blueManager.connect(CBPer, options: nil)
    }

}


extension BluetoothManager:CBCentralManagerDelegate,CBPeripheralDelegate{
    
    //扫描
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral == nil || !(peripheral.name != nil) || peripheral.name == "" {
            return
        }
        
        let CBPs = self.blueSystems.filter { (CBPer) -> Bool in
            return CBPer.identifier == peripheral.identifier
        }
        if CBPs.count < 1 {
            self.blueSystems.append(peripheral)
            if let clo = self.infoBackClosure{
                clo(self.blueSystems)
            }
        }
        
        print(peripheral.name ?? "")

    }
    
    //连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == nil{
            return
        }
        self.blueManager.stopScan()
        
//        NotificationCenter.default.post(name: <#T##NSNotification.Name#>, object: <#T##Any?#>, userInfo: <#T##[AnyHashable : Any]?#>)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("链接失败")
    }
    
    //获取services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if peripheral != self.peripheral{
            return
        }
        
        if let er = error {
            print("error = \(er)")
            return
        }
        
        if let services = peripheral.services {
            if services.count < 0{
                print("services < 0")
            }else{
                for cbs in services{
                    print("cbs = \(cbs.uuid.uuidString)")
                }
            }
        }
    
    }
    
    //发现character
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if peripheral != self.peripheral{
            return
        }
        
        if let er = error {
            print("error = \(er)")
            return
        }
        
        if let characteristic = service.characteristics{
            for cha in characteristic{
                print("char = \(cha.uuid.uuidString)")
            }
        }
    }
    
    //外设断开链接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //外设断开可以重新链接
        self.blueManager.connect(peripheral, options: nil)
    }
    
    //主动断开链接
    func cancelPeripheralConnection(){
        if self.peripheral != nil {
            self.blueManager.cancelPeripheralConnection(self.peripheral!)
        }else{
            self.blueManager.stopScan()
        }
    }
    
    //读取数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("characteristic")
        if let data = characteristic.value{
            print(data)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写数据")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("无法获取设备脸呀状态")
            break
        case .resetting:
            print("蓝牙重置")
            break
        case .unsupported:
            print("该设备不支持蓝牙")
            break
        case .unauthorized:
            print("未授权蓝牙权限")
            break
        case .poweredOff:
            print("蓝牙已关闭")
            break
        default:
            print("蓝牙开启")
            self.startBlue()
            break
        }
    }
    
    
}
