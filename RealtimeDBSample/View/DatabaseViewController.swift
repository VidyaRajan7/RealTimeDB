//
//  DatabaseViewController.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 21/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import FirebaseDatabase
import UIKit

class DatabaseViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    let conditionRef = Database.database().reference().child("condition")
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        conditionRef.observe(.value, with: {(snapshot) in
            let disValue = snapshot.value
            
            self.displayLabel.text = disValue as? String

        })
       

    }
    @IBAction func didTapSunny(_ sender: UIButton) {
        conditionRef.setValue("Sunny")
    }
    @IBAction func didTapFoggy(_ sender: UIButton) {
        conditionRef.setValue("Foggy")
    }
    
}
