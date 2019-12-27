//
//  LoginViewController.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 26/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    func initialSetUp() {
        //On successful authentication, perform the segue and clear the text fields’ text without showing the login page again
        Auth.auth().addStateDidChangeListener(){auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
            }
        }
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 0,
            password.count > 0
            else {
            return
        }
        // authenticate the user when they attempt to log in by tapping the Login button.
        Auth.auth().signIn(withEmail: email, password: password, completion: {user,error in
            if let error = error,user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } 
        })
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {
        
        let alert = UIAlertController(title: "Register",
        message: "Register",
        preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!)  {user, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: nil)
                }
            }
    }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    if textField == passwordTextField {
      textField.resignFirstResponder()
    }
    return true
  }
}
