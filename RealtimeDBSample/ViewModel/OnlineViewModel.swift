//
//  OnlineViewModel.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 28/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import Foundation
struct OnlineViewModel {
    let usersRef = Database.database().reference(withPath: "online")
    var currentUsers: [String] = []
    

}
