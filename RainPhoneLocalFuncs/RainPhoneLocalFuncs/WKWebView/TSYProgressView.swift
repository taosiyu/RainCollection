//
//  TSYProgressView.swift
//  RainPhoneLocalFuncs
//
//  Created by ncm on 2017/4/17.
//  Copyright © 2017年 TSY. All rights reserved.
//

import UIKit

//进度条
class TSYProgressView: UIView {
    
    fileprivate let progressV = TSYProgressSubView()
    
    var backColor = UIColor.white {
        didSet {
            backgroundColor = backColor
        }
    }
    
    var frontColor = UIColor.blue {
        didSet {
            progressV.backgroundColor = frontColor
        }
    }
    
    var startProgress: CGFloat = 0 {
        didSet {
            self.setWidthLayout()
        }
    }
    
    var endProgress: CGFloat = 0 {
        didSet {
            update4endProgress()
            self.setWidthLayout()
        }
    }
    
    //MARK:Funcs
    func setProgress(progress: CGFloat, animated: Bool) {
        setStartProgress(startProgress: 0, endProgress: progress, animated: animated)
    }
    
    func setStartProgress(startProgress: CGFloat, endProgress: CGFloat, animated: Bool) {
        self.startProgress = startProgress
        self.endProgress = endProgress
        
        let progressClosure = {
            self.progressV.layoutSubviews()
        }
        
        let completionClosure = {
            if self.endProgress == 1.0 {
                let alphaClosure = {
                    self.alpha = 0
                }
                
                if animated {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: alphaClosure, completion: nil)
                } else {
                    alphaClosure()
                }
            }
        }
        
        if animated {
            self.setWidthLayout()
            UIView.animate(withDuration: 0.3, animations: progressClosure, completion: { (_) in
                completionClosure()
            })
        } else {
            progressClosure()
            completionClosure()
        }
    }
    
    private func update4endProgress() {
        if endProgress > 0 && endProgress < 1 {
            alpha = 1
        } else {
            alpha = 0
        }
    }
    
    convenience init() {
        self.init(progress: 0)
    }
    
    convenience init(progress: CGFloat) {
        self.init(startProgress: 0, endProgress: progress)
    }
    
    init(startProgress: CGFloat, endProgress: CGFloat) {
        super.init(frame: CGRect())
        
        self.startProgress = startProgress
        self.endProgress = endProgress
        update4endProgress()
        
        self.addSubview(self.progressV)
        
        self.progressV.translatesAutoresizingMaskIntoConstraints = false
        
        self.layoutInit()
        
    }
    
    private func layoutInit(){
        //约束
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: self.progressV, attribute: NSLayoutAttribute.height, relatedBy:NSLayoutRelation.equal, toItem:self, attribute: NSLayoutAttribute.height, multiplier:1.0, constant:0)
        self.addConstraint(height)
        
        let left:NSLayoutConstraint = NSLayoutConstraint(item: self.progressV, attribute: NSLayoutAttribute.left, relatedBy:NSLayoutRelation.equal, toItem:self, attribute: NSLayoutAttribute.left, multiplier:1, constant:(startProgress * (UIScreen.main.bounds.width)))
        self.addConstraint(left)
        
        let bottom:NSLayoutConstraint = NSLayoutConstraint(item: self.progressV, attribute: NSLayoutAttribute.bottom, relatedBy:NSLayoutRelation.equal, toItem:self, attribute: NSLayoutAttribute.bottom, multiplier:1.0, constant:0)
        self.addConstraint(bottom)
        
        let top:NSLayoutConstraint = NSLayoutConstraint(item: self.progressV, attribute: NSLayoutAttribute.top, relatedBy:NSLayoutRelation.equal, toItem:self, attribute: NSLayoutAttribute.top, multiplier:1.0, constant:0)
        self.addConstraint(top)
        
        setWidthLayout()
    }
    
    private var w:NSLayoutConstraint?
    private func setWidthLayout(){
        if let w = self.w {
            self.removeConstraint(w)
        }
        let width:NSLayoutConstraint = NSLayoutConstraint(item: self.progressV, attribute: NSLayoutAttribute.width, relatedBy:NSLayoutRelation.equal, toItem:self, attribute: NSLayoutAttribute.width, multiplier:(endProgress - startProgress), constant:0)
        w = width
        self.addConstraint(width)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension TSYProgressView{
    
    
}

//显示部分默认2的高
class TSYProgressSubView: UIView {
    override var intrinsicContentSize: CGSize{
        get{
            return CGSize(width:0, height:2)
        }
    }
}
