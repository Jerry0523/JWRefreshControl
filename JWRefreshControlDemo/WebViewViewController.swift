//
//  WebViewViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.scrollView.addCustomRefreshHeader { [weak self] (header: RefreshHeaderControl<SloganHeaderContentView>) in
            self?.webView.reload()
            header.loadedSuccess()
        }
        
        let refreshHeader = self.webView.scrollView.refreshHeader as? RefreshHeaderControl<SloganHeaderContentView>
        refreshHeader?.style = .follow
        
        self.webView.load(URLRequest.init(url: URL.init(string: "https://www.baidu.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
