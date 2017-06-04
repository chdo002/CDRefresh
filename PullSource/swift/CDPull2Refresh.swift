
//
//  CDPull2Refresh.swift
//  CDPullDemo_Swift
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

import UIKit

fileprivate var RefreshViewKey = "RefreshViewKey"
extension UIScrollView {
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
    
    
    func addPullRefresh(_ refreshHandler:@escaping () -> Void, pullingHandler: ((_ refreshView: UIView, _ percent: CGFloat) -> Void)? = nil) {
        
        if let ref = objc_getAssociatedObject(self, &RefreshViewKey) as? CDRefreshView {
            ref.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshViewKey, nil, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        let ref = CDRefreshView()
        addSubview(ref)
        
        ref.refreshAction = refreshHandler
        ref.pullingHandler = pullingHandler
        
        objc_setAssociatedObject(self, &RefreshViewKey, ref, .OBJC_ASSOCIATION_ASSIGN)
    }
}


private class CDRefreshView: UIView {
    
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height
    

    enum CDRefreshState {
        case normal
        case pulling(percent: CGFloat)
        case refreshing
    }
    
    
    /****************************************/
    
    weak var scroll: UIScrollView?
    let pullMark: CGFloat = 60;
    
    var originInset: UIEdgeInsets?
    var originOffset: CGPoint?
    
    lazy var loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var refreshAction: (()-> Void)?
    var pullingHandler: ((_ refreshView: UIView, _ percent: CGFloat)-> Void)?
    
    var state : CDRefreshState = .normal {
        
        didSet{
            switch state {
            case .pulling(percent: let per):
                // 只有oldValue是normal或者pulling态才会进入此处
                if let handler = self.pullingHandler {
                    handler(self, per)
                } else {
                    self.alpha = pow(per, 2.5) // 非线性的透明度变化好看一点
                }
            case .normal:
                // 只有oldValue是refreshing或者pulling态才会进入此处
//                switch oldValue {
//                case .pulling(percent: _):
//                    toogleIntoNoramlState()
//                case .refreshing:
                    if (scroll?.contentOffset.y)! > pullMark {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.scroll?.contentInset = self.originInset!
                            self.alpha = 0
                        }) { (bol) in
                        }
                    } else {
                        toogleIntoNoramlState()
                    }
//                default:
//                    return
//                }
            case .refreshing:
                // 只有oldValue是normal或者pulling态才会进入此处
                switch oldValue {
                case .normal, .pulling(percent: _):
                    toogleIntoRefreshState()
                default:
                    return
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
        self.stopAnimation()
    }
    
    
    func toogleIntoNoramlState() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.scroll?.contentInset = self.originInset!
            self.scroll?.contentOffset = self.originOffset!
            self.alpha = 0
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
            self.alpha = 1
        }) { (bol) in
            if bol {
                self.refreshAction?()
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
        
        if keyPath == "contentOffset" && context == &obsesrver {
            switch state {
            case .normal , .pulling(percent: _):
                if  let offset = change?[.newKey] as? CGPoint,
                    let scrollView = self.scroll
                {
                    if scrollView.isDragging {
                        
                        var per: CGFloat =  scrollView.contentOffset.y / pullMark
                        per = min(per, 0)
                        per = max(per, -1)
                        state = .pulling(percent: -per)
                    } else if scrollView.isDecelerating {
                        if -offset.y > pullMark {
                            state = .refreshing
                        }
                    }
                }
            default:
                return
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        scroll?.removeObserver(self, forKeyPath: "contentOffset")
    }
}
