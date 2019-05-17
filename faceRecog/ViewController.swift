//
//  ViewController.swift
//  FaceLogin
//
//  Created by William Huang on 9/13/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        performSegue(withIdentifier: "SignUp", sender: nil)
    }
}

