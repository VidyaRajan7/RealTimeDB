//
//  GroceryListViewController.swift
//  RealtimeDBSample
//
//  Created by Developer Admin on 26/11/19.
//  Copyright © 2019 Developer Admin. All rights reserved.
//
import Firebase
import FirebaseAuth
import UIKit

class GroceryListViewController: UIViewController {

    @IBOutlet weak var navigationbarItem: UINavigationItem!
    var groceryListViewModel: GroceryListViewModel = GroceryListViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
         
        initialSeUp()
        //testCase()
    }
    func testCase() {
        groceryListViewModel.ref.queryOrdered(byChild: "name").queryLimited(toLast: 6).observe(.childAdded, with: {snapshot in
            
            print("The /\(snapshot.key) is/\(snapshot.value)")
        })
        
        let connectRef = Database.database().reference(withPath: ".info/connected")
        connectRef.observe(.value, with: {snapshot in
            if snapshot.value as? Bool ?? false {
                print("connected")
            } else {
                print("disconnected")
            }
        })
        
        let timeRef = Database.database().reference(withPath: ".info/serverTimeOffset")
        timeRef.observe(.value, with: { snapshot in
            if let offset = snapshot.value as? TimeInterval {
                print("time = \(Date().timeIntervalSince1970 * 1000 + offset)")
                
            }
        })
        
        //check.......................
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = Database.database().reference(withPath: "users/morgan/connections")

        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = Database.database().reference(withPath: "users/morgan/lastOnline")

        let connectedRef = Database.database().reference(withPath: ".info/connected")

        connectedRef.observe(.value, with: { snapshot in
          // only handle connection established (or I've reconnected after a loss of connection)
          guard let connected = snapshot.value as? Bool, connected else { return }

          // add this device to my connections list
          let con = myConnectionsRef.childByAutoId()

          // when this device disconnects, remove it.
          con.onDisconnectRemoveValue()

          // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
          // where you set the user's presence to true and the client disconnects before the
          // onDisconnect() operation takes effect, leaving a ghost user.

          // this value could contain info about the device or a timestamp instead of just true
          con.setValue(true)

          // when I disconnect, update the last time I was seen online
          lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
        })
        
    }
    func initialSeUp() {
        //navigation bar setup
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGrocery))
        let onlineButton = UIBarButtonItem(title: "Online", style: .plain, target: self, action: #selector(didTapOnline))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(didTapOnline))
        self.navigationbarItem.rightBarButtonItems = [addButton,onlineButton]
        
        //Add user count on top of the navigationbar
        self.groceryListViewModel.usersRef.observe(.value, with: {snapshot in
            if snapshot .exists() {
                self.navigationItem.leftBarButtonItem?.title =  snapshot.childrenCount.description
            } else {
                self.navigationItem.leftBarButtonItem?.title = "0"
            }
        })
        
        //"queryOrdered" is used to order marked items
        groceryListViewModel.ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems : [GroceryItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let groceryItem = GroceryItem(snapshot: snapshot){
                    newItems.append(groceryItem)
                }
            }
            self.groceryListViewModel.items = newItems
            self.tableView.reloadData()
        })
        
        //Attach an authentication observer to the Firebase auth object, which in turn assigns the user property when a user successfully signs in. And shows which users are online
        Auth.auth().addStateDidChangeListener(){auth,user in
            guard let user = user else { return}
            self.groceryListViewModel.user = User(authData: user)
              if let currentUserId = self.groceryListViewModel.user?.uid {
                      //Create a child reference using a user’s uid, which is generated when Firebase creates an account
                let currentUserRef = self.groceryListViewModel.usersRef.child(currentUserId)
                      //Use this reference to save the current user’s email.
                      currentUserRef.setValue(self.groceryListViewModel.user?.email)
                      
                      //Call onDisconnectRemoveValue() on currentUserRef. This removes the value at the reference’s location after the connection to Firebase closes, for instance when a user quits your app.
                      currentUserRef.onDisconnectRemoveValue()
        }
        
      
        }
        
    }
    @objc func didTapOnline() {
        self.performSegue(withIdentifier: "toOnlineSegue", sender: self)
    }
    @objc func signOutAction()
    {
        self.dismiss(animated: false, completion: nil)
    }
    @objc func addGrocery(sender:UIButton) {
        let alert = UIAlertController(title: "Grocery Item", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
            guard let textField = alert.textFields?.first,
              let text = textField.text,
                let email = self.groceryListViewModel.user?.email
                                        else { return }
            
            let groceryItem = GroceryItem(name: text,
                                          addedByUser: email ,
                                     completed: false)
            let groceryItemRef = self.groceryListViewModel.ref.child(text.lowercased())
            groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    func toggledCellCompletion( _ cell:UITableViewCell,isCompleted: Bool) {
        if !isCompleted {
          cell.accessoryType = .none
          cell.textLabel?.textColor = .black
          cell.detailTextLabel?.textColor = .black
        } else {
          cell.accessoryType = .checkmark
          cell.textLabel?.textColor = .gray
          cell.detailTextLabel?.textColor = .gray
        }
    }
}
extension GroceryListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryListViewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groceryCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let groceryItem = groceryListViewModel.items[indexPath.row]
        groceryCell.textLabel?.text = groceryItem.name
        groceryCell.detailTextLabel?.text = groceryItem.addedByUser
        toggledCellCompletion(groceryCell, isCompleted: groceryItem.completed)
        return groceryCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return}
        let groceryItem = groceryListViewModel.items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        toggledCellCompletion(cell, isCompleted: toggledCompletion)
        groceryItem.ref?.updateChildValues(["completed":toggledCompletion])
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = groceryListViewModel.items[indexPath.row] 
          groceryItem.ref?.removeValue()
        }
    }
    
    
}
