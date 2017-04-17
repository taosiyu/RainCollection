//
//  WKWebViewController.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/15.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit
import WebKit

//WKWebView，js和native交互
class WKWebViewController: UIViewController {
    
    fileprivate var myWebView:WKWebView!
    
    fileprivate var urlStr = ""
    
    fileprivate var theTitle = ""
    
    fileprivate var progressV:TSYProgressView = {
        let vc = TSYProgressView.init(progress: 0)
        vc.backgroundColor = UIColor.gray
        vc.frontColor = UIColor.blue
        vc.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 2)
        return vc
    }()
    
    init(urlStr: String, title: String) {
        self.urlStr = urlStr
        self.theTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var myContext:NSObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.theTitle
        
        myWebView = WKWebView()
        view.addSubview(myWebView)
        myWebView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.setupViews()
        
        //webView
        let req = URLRequest.init(url: URL.init(string: self.urlStr)!)
//        req.setValue("Token \(userToken())", forHTTPHeaderField: "Authorization")
        self.myWebView.load(req)
        myWebView.navigationDelegate = self
        
        myWebView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: &myContext)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                if let progress = newValue as? Double{
                    self.progressV.setProgress(progress: CGFloat(progress), animated: true)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func setupViews(){
        self.view.addSubview(self.progressV)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        self.myWebView.configuration.userContentController.removeScriptMessageHandler(forName: "")
        myWebView.removeObserver(self, forKeyPath: "estimatedProgress", context:&myContext)
        //删除所有注入的js
        myWebView.configuration.userContentController.removeAllUserScripts()
        print("MyWebVIew deinit")
    }
    
}

//MARK:alert，confirm拦截
extension WKWebViewController:WKUIDelegate{
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: myWebView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (a) -> Void in
            completionHandler()
        }))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
            { (ac) -> Void in
                completionHandler(true)  //按确定的时候传true
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:
            { (ac) -> Void in
                completionHandler(false)  //取消传false
        }))
        
        self.present(ac, animated: true, completion: nil)
        
    }
    
}

extension WKWebViewController:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "name"//此处name为JS传出信息打包的标志<name>
        {
            //用message.body获得JS传出的参数体
        }
    }
    
    //MARK:设置js交互config
    func setJavascriptConfig(){
        self.myWebView.configuration.userContentController.add(self, name: "NativeJS")
        
        //利用evaluateJavaScript触发js
        
        //声明一个WKUserScript对象
        //let script:WKUserScript = WKUserScript(source: "function callJavaScript() {ObjCToJavaScript('\(name)');}", injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        
        //对Script对象进行添加
        //configuration.userContentController.addUserScript(script)
    }
    
}

extension WKWebViewController:WKNavigationDelegate{
    
    //MARK: - 清空缓存
    func clearCache() -> Void {
        let dateFrom: NSDate = NSDate.init(timeIntervalSince1970: 0)
        if #available(iOS 9.0, *) {
            let websiteDataTypes: NSSet = WKWebsiteDataStore.allWebsiteDataTypes() as NSSet
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: dateFrom as Date, completionHandler: {
                print("清空WKWebView缓存成功")
            })
        } else {
            let libPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
            let cookiesPath = ("\(libPath)/Cookies")
            _ = try?FileManager.default.removeItem(atPath: cookiesPath)
        }
    }
    
    //MARK:WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("页面开始加载时调用")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("当内容开始返回时调用")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成")
        //取消长按响应
        self.setLongClickFail()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("页面加载失败时调用")
    }
    // 接收到服务器跳转请求之后调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("111")
    }
    
    // 在收到响应后，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(navigationResponse.response.mimeType ?? "")
        decisionHandler(.allow) //全部允许
    }
    
    // 在发送请求之前，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.navigationType == .linkActivated){
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    //MARK:各种config
    func setLongClickFail(){
        self.myWebView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
    }
    
}
