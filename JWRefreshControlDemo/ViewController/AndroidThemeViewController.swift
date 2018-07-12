//
//  AndroidThemeViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2018/7/12.
//  Copyright © 2018年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

class AndroidThemeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addCustomRefreshHeader { (header: RefreshHeaderControl<AndroidThemeContentView>) in
            header.success()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
