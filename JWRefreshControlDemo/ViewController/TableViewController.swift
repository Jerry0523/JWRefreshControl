//
//  TableViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

private let reuseIdentifier = "default"
private let batchCount = 10

class TableViewController: UITableViewController {
    
    var data: [Int] = {
        var data: [Int]?
        FakeRequest.createMockData(forStartIndex: 1, callBack: { (output) in
            data = output
        }, delay: nil)
        return data!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addRefreshHeader { [weak self] (header) in
            if self == nil {
                return
            }
            
            FakeRequest.createMockData(forStartIndex: 1, callBack: { [weak self] (output) in
                self?.data = output
                header.success()
                self?.tableView.reloadData()
            })
        }
        
        tableView.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }
            
            if self!.data.count >= 60 {
                footer.pause(withMsg: "No More Data")
            } else {
                FakeRequest.createMockData(forStartIndex: self!.data.count + 1, callBack: { [weak self] (output) in
                    self?.data.append(contentsOf: output)
                    footer.success()
                    self?.tableView.reloadData()
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "This is line \(data[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
            label.text = "  Hello Title"
            label.backgroundColor = UIColor.white
            return label
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30.0
        }
        return 0
    }
}

