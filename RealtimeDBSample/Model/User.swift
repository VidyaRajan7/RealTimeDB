//
//  User.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 26/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import Foundation

struct User {
    let email : String
    let uid : String
    init(authData: Firebase.User) {
      uid = authData.uid
      email = authData.email!
    }
    init(email:String,uid:String) {
        self.email = email
        self.uid = uid
    }
}
