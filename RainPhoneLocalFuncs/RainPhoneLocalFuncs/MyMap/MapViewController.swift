//
//  MapViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/17.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    fileprivate var myMapView:MKMapView = {
        let vc = MKMapView.init()
        return vc
    }()
    
    //定位管理器
    fileprivate lazy var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    fileprivate func setupView(){
        self.setMapView()
        self.setLocationManager()
    }
    
    //MARK:设置定位信息
    fileprivate func setLocationManager(){
        //设置定位服务管理器代理
        locationManager.delegate = self
        //设置定位进度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距离
        locationManager.distanceFilter = 100
        ////发送授权申请
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled())
        {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            print("定位开始")
        }
        
    }
    
    //定位改变执行，可以得到新位置、旧位置
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //获取最新的坐标
        let currLocation:CLLocation = locations.last!
        print("经度：\(currLocation.coordinate.longitude)")
        print("纬度：\(currLocation.coordinate.latitude)")
        print("海拔：\(currLocation.altitude)")
        print("水平精度：\(currLocation.horizontalAccuracy)")
        print("垂直精度：\(currLocation.verticalAccuracy)")
        print("方向：\(currLocation.course)")
        print("速度：\(currLocation.speed)")

    }
    
    //MARK:地图设置
    fileprivate func setMapView(){
        self.myMapView.frame = self.view.frame
        self.view.addSubview(self.myMapView)
        
        //地图类型设置 - 标准地图
        self.myMapView.mapType = MKMapType.standard
        self.myMapView.delegate = self
        
        self.myMapView.showsUserLocation = true
        
        //定义地图区域和中心坐标（
        //使用当前位置
        //        let center:CLLocation = locationManager.location!
        //使用自定义位置
        let center:CLLocation = CLLocation(latitude: 31.01978, longitude: 121.639102)

        self.showCurrentRegion(center: center)
        
        self.addAnnotation(cllocation: CLLocation(latitude: 32.029171,
                                                  longitude: 118.788231), placeMark: nil)
        
        self.reverseGeocode(cllocation: center)
        
        self.locationEncode()
    }
    
    //MARK:显示当前区域
    fileprivate func showCurrentRegion(center:CLLocation?){
        //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        if let location = center {
            let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: location.coordinate,span: currentLocationSpan)
            //设置显示区域
            self.myMapView.setRegion(currentRegion, animated: true)
        }else{
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func addAnnotation(cllocation:CLLocation?,placeMark:CLPlacemark?){
        
        if let cllocationValue = cllocation {
            //创建一个大头针对象
            let objectAnnotation = MKPointAnnotation()
            //设置大头针的显示位置
            objectAnnotation.coordinate = cllocationValue.coordinate
            //设置点击大头针之后显示的标题
            objectAnnotation.title = "尚街Loft"
            //设置点击大头针之后显示的描述
            objectAnnotation.subtitle = "上海市徐汇区建国西路283号"
            //添加大头针
            self.myMapView.addAnnotation(objectAnnotation)
        }

    }
    
}

extension MapViewController:CLLocationManagerDelegate{
     //地理信息反编码
    func reverseGeocode(cllocation:CLLocation){
        let geocoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude)
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            let array = NSArray(object: "zh-hans")
            UserDefaults.standard.set(array, forKey: "AppleLanguages")
            //显示所有信息
            if error != nil {
                //print("错误：\(error.localizedDescription))")
                print("错误：\(error!.localizedDescription))")
                return
            }
            
            if let p = placemarks?[0]{
                //print(p) //输出反编码信息
                print("获取到名字是\(p.name)")
            } else {
                print("No placemarks!")
            }

        }
    }
    
    
    //地理信息编码
    func locationEncode(){
        let geocoder = CLGeocoder()
        //这里地址可以自定义
        geocoder.geocodeAddressString("南京市秦淮区秦淮河北岸中华路") { (placemarks, error) in
            if error != nil {
                print("错误：\(error!.localizedDescription))")
                return
            }
            if let p = placemarks?[0]{
                print("经度：\(p.location!.coordinate.longitude)  "
                    + "纬度：\(p.location!.coordinate.latitude)")
                self.addAnnotation(cllocation: p.location, placeMark: nil)
                self.showCurrentRegion(center: p.location)
            } else {
                print("No placemarks!")
            }
        }
    }
    
}

//MARK:MKMapViewDelegate
extension MapViewController: MKMapViewDelegate{
    //自定义大头针样式
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuserId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId)
                as? MKPinAnnotationView
            if pinView == nil {
                //创建一个大头针视图
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
                pinView?.canShowCallout = true
                pinView?.animatesDrop = true
                //设置大头针颜色
                pinView?.pinTintColor = UIColor.green
                //设置大头针点击注释视图的右侧按钮样式
                pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }else{
                pinView?.annotation = annotation
            }
            
            return pinView
    }
    
    //MARK:各种回调
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("地图缩放级别发送改变时")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("地图缩放完毕触法")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("开始加载地图")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("地图加载结束")
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("地图加载失败")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("开始渲染下载的地图块")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("渲染下载的地图结束时调用")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("正在跟踪用户的位置")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("停止跟踪用户的位置")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("更新用户的位置")
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("跟踪用户的位置失败")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        print("改变UserTrackingMode")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
        -> MKOverlayRenderer {
            print("设置overlay的渲染")
            return MKPolylineRenderer()
    }
    
    private func mapView(mapView: MKMapView,
                         didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        print("地图上加了overlayRenderers后调用")
    }
    
    /*** 下面是大头针标注相关 *****/
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("添加注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("点击注释视图按钮")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("取消点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        print("移动annotation位置时调用")
    }
}
