//
//  ScrollViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/12/6.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addCustomRefreshHeader { (header: RefreshHeaderControl<GifContentView>) in
            header.loadedSuccess()
        }
        
        let refreshHeader = scrollView.refreshHeader as? RefreshHeaderControl<GifContentView>
        refreshHeader?.style = .follow

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
