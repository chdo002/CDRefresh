//
//  ViewController.swift
//  CDPullDemo_Swift
//
//  Created by chdo on 2017/6/3.
//  Copyright © 2017年 chdo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    var source: Int = 29 {
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        
        table.addPullRefresh({
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: { 
                self.source += 1
                self.table.reloadData()
                self.table.stopRefreshing()
            })
            
        }) { (refView, per) in
            refView.alpha = pow(per, 4)
        }
        table.backgroundColor = UIColor.brown
        table.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
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

