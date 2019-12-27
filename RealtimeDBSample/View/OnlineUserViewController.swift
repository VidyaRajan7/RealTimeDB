//
//  OnlineUserViewController.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 28/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit

class OnlineUserViewController: UIViewController {

    @IBOutlet weak var onlineNavigationItem: UINavigationItem!
    @IBOutlet weak var tableview: UITableView!
    var onlineViewModel: OnlineViewModel = OnlineViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
       initialSetup()
    }
    func initialSetup() {
        //navigation item setup
        self.onlineNavigationItem.rightBarButtonItem = UIBarButtonItem(title: "SignOut", style: .plain, target: self, action: #selector(didTapSignOut))
        self.navigationItem.title = "Online"
        
        //Displaying a List of  Users when they are online
        self.onlineViewModel.usersRef.observe(.childAdded, with: {snap in
            guard let email = snap.value as? String else { return}
            self.onlineViewModel.currentUsers.append(email)
            let row = self.onlineViewModel.currentUsers.count-1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableview.insertRows(at: [indexPath], with: .top)
            //self.tableview.reloadData()
        })
        //Remove users from list when they go offline
        self.onlineViewModel.usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else {return}
            for (index,email) in self.onlineViewModel.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.onlineViewModel.currentUsers.remove(at: index)
                    self.tableview.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
    }
    @objc func didTapSignOut() {
        if let user = Auth.auth().currentUser {
                let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
                onlineRef.removeValue { (error, _) in
                    if let error = error {
                        print("Removing online failed: \(error)")
                        return
                    }
                    do {
                        try Auth.auth().signOut()
                        self.dismiss(animated: true, completion: nil)
                    } catch (let error) {
                        print("Auth sign out failed: \(error)")
                    }
                }
                
            }
        }

}
extension OnlineUserViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onlineViewModel.currentUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let onlineCell = tableView.dequeueReusableCell(withIdentifier: "onlineCellId", for: indexPath)
        onlineCell.textLabel?.text = self.onlineViewModel.currentUsers[indexPath.row]
        
        return onlineCell
    }
    
    
}
