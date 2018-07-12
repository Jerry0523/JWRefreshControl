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

class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.scrollView.addCustomRefreshHeader { [weak self] (header: RefreshHeaderControl<SloganContentView>) in
            self?.webView.reload()
        }        
        webView.load(URLRequest.init(url: URL(string: "https://www.apple.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.refreshHeader?.success(withDelay: 1.0)
    }

}
