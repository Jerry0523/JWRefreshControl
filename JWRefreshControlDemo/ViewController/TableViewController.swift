//
//  TableViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit

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
                header.loadedSuccess()
                self?.tableView.reloadData()
            })
        }
        
        tableView.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }
            
            if self!.data.count >= 60 {
                footer.loadedPause(withMsg: "No More Data")
            } else {
                FakeRequest.createMockData(forStartIndex: self!.data.count + 1, callBack: { [weak self] (output) in
                    self?.data.append(contentsOf: output)
                    footer.loadedSuccess()
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
}

