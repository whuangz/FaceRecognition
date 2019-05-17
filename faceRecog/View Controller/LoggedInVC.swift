//
//  LoggedInVC.swift
//  FaceLogin
//
//  Created by William Huang on 9/14/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit

class LoggedInVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: nil)
    }
}

