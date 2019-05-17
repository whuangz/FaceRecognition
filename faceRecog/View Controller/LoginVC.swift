//
//  LoginVC.swift
//  FaceLogin
//
//  Created by William Huang on 9/14/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase
class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            let cameraVC = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! CameraVC
            cameraVC.photoType = .login
            self.present(cameraVC, animated: true, completion: nil)
            
        }
    }
    
}

