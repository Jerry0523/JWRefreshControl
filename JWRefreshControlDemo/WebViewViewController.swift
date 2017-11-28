//
//  WebViewViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import WebKit
import JWRefreshControl

class WebViewViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.addCustomRefreshHeader { [weak self] (header: RefreshHeaderControl<SloganHeaderContentView>) in
            self?.webView.reload()
            header.loadedSuccess()
        }
        
        let refreshHeader = webView.scrollView.refreshHeader as? RefreshHeaderControl<SloganHeaderContentView>
        refreshHeader?.style = .follow
        
        webView.load(URLRequest.init(url: URL.init(string: "https://www.baidu.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
