//
//  MainViewController.swift
//  Denomination
//
//  Created by Alexander Bekert on 5/28/17.
//  Copyright © 2017 Alexander Bekert. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let topColor = UIColor(rgbValue: 0xD49A84)
    let bottomColor = UIColor(rgbValue: 0xAA7062)
    
    @IBOutlet var backgroundView: GradientView!
    @IBOutlet weak var statusBarView: GradientView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.gradientColors = [topColor, bottomColor]
        statusBarView.gradientColors = [topColor, topColor, topColor.withAlphaComponent(0)]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        statusBarView.isHidden = self.prefersStatusBarHidden
    }
}
