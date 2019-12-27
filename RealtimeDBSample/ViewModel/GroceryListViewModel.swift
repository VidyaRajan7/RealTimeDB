//
//  GroceryViewModel.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 26/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import Foundation

struct GroceryListViewModel {
    let ref = Database.database().reference(withPath: "grocery-items")
    let usersRef = Database.database().reference(withPath: "online")
    var user: User?
    var items: [GroceryItem] = []

}
