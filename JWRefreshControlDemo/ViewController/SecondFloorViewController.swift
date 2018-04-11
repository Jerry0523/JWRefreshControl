//
//  SecondFloorViewController.swift
//  JWRefreshControlDemo
//
//  Created by 王杰 on 2018/4/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

import UIKit

class SecondFloorViewController: UIViewController {
    
    @IBOutlet weak var button0: UIButton!
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button0.transform = CGAffineTransform(translationX: 80.0, y: 80.0)
        button1.transform = CGAffineTransform(translationX: -80.0, y: 80.0)
        button2.transform = CGAffineTransform(translationX: 80.0, y: -80.0)
        button3.transform = CGAffineTransform(translationX: -80.0, y: -80.0)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeLinear, animations: {
            for (index, element) in [self.button0, self.button1, self.button2, self.button3].enumerated() {
                UIView.addKeyframe(withRelativeStartTime: Double(index + 1) / 4.0, relativeDuration: 1.0 / 4.0, animations: {
                    element?.transform = CGAffineTransform.identity
                })
            }
        }, completion: nil)
        
    }
    
    @IBAction func didClickCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
