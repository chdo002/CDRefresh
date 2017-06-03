
//
//  CDPull2Refresh.swift
//  CDPullDemo_Swift
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

import UIKit

fileprivate var RefreshViewKey = "RefreshViewKey"
extension UITableView {
    func startRefresh() {
        
        if let ref = objc_getAssociatedObject(self, &RefreshViewKey) as? CDRefreshView {
            ref.startRefresh()
        }
    }
    
    func stopRefreshing() {
        if let ref = objc_getAssociatedObject(self, &RefreshViewKey) as? CDRefreshView {
            ref.stopRefresh()
        }
    }
    
    
    func addPullRefresh(_ refreshHandler:@escaping () -> Void) {
        
        let ref = CDRefreshView()
        addSubview(ref)
        ref.pullAction = refreshHandler
        objc_setAssociatedObject(self, &RefreshViewKey, ref, .OBJC_ASSOCIATION_ASSIGN)
        
        
    }
}


private class CDRefreshView: UIView {
    
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height
    

    enum CDRefreshState {
        case normal
        case pulling
        case refreshing
    }
    
    
    /****************************************/
    
    var scroll: UIScrollView?
    let pullMark: CGFloat = 60;
    
    var originInset: UIEdgeInsets?
    var originOffset: CGPoint?
    
    
    
    lazy var loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var pullAction: (()-> Void)?
    
    var state : CDRefreshState = .normal {
        
        didSet{
            
            if oldValue != state {
                switch state {
                case .normal:
                    toogleIntoNoramlState()
                case .pulling:
                    print(123)
                case .refreshing:
                    toogleIntoRefreshState()
                }
            }
        }
        
    }
    
    init() {
        
        let rect = CGRect(x: 0, y: -pullMark, width: screenW, height: pullMark)
        super.init(frame: rect)
    
        self.backgroundColor = UIColor.clear

        loading.hidesWhenStopped = false
        loading.frame = self.bounds
        addSubview(loading)
        
    }
    
    
    var obsesrver:Int8 = 1
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        scroll = self.superview as? UIScrollView
        originInset = scroll?.contentInset
        originOffset = scroll?.contentOffset
        
        scroll?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &obsesrver)
    }
    
    func startRefresh() {
        self.state = .refreshing
    }
    
    func stopRefresh() {
        self.state = .normal
    }
    
    
    func toogleIntoNoramlState() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.scroll?.contentInset = self.originInset!
            self.scroll?.contentOffset = self.originOffset!
        }) { (bol) in
            if bol {
                
            }
        }
    }
    
    func toogleIntoRefreshState() {
        UIView.animate(withDuration: 0.25, animations: { 
            if var inset = self.scroll?.contentInset {
                inset.top = self.pullMark + inset.top
                self.scroll?.contentInset = inset
                
                if var offSet = self.scroll?.contentOffset {
                    offSet.y = -inset.top
                    self.scroll?.contentOffset = offSet
                }
            }
        }) { (bol) in
            if bol {
                self.pullAction?()
                self.startAnimation()
            }
        }
    }
    
    func startAnimation() {
        loading.startAnimating()
    }
    
    func stopAnimation() {
        loading.stopAnimating()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentOffset" {
            
            guard state != .refreshing  else { return }
            
            if  let offset = change?[.newKey] as? CGPoint,
                let scrollView = self.scroll
            {
                if scrollView.isDragging {
                    self.state = .pulling
                } else if scrollView.isDecelerating {
                    if -offset.y > pullMark {
                        self.state = .refreshing
                    } else {
                        self.state = .normal
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
