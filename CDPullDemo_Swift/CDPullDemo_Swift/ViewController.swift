//
//  ViewController.swift
//  CDPullDemo_Swift
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        table.addPullRefresh({
//          print("refreshing")
//        })
//        

        table.addPullRefresh({
            print("refreshing")
        }) { (refView, per) in
            refView.alpha = pow(per, 4)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startSrefresh(_ sender: UIButton) {
        table.startRefresh()
    }

    @IBAction func stopSrefresh(_ sender: UIButton) {
        table.stopRefreshing()
    }
}

