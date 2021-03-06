//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Jules Frantz Stephane Loubeau on 10/9/18.
//  Copyright © 2018 Jules Frantz Stephane Loubeau. All rights reserved.
//

import UIKit
import Parse



class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

        var messages = [PFObject]()
    var refreshControl: UIRefreshControl!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    

    @IBAction func logoutUser(_ sender: Any) {
        
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let user = PFUser.current() ?? nil
                print("Successful logout")
                print(user as Any)
                
            }
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    
        // Do any additional setup after loading the view.
        
       
        self.tableView.reloadData()
        
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
        if let currentUser = PFUser.current() {
            //labelWelcome.text = "Welcome back \(currentUser.username!) 😀"
        }else {
            let user = PFUser()
            //labelWelcome.text = "Welcome \(user)"
        }
        
    }
    
    
    

    @IBAction func sendMessage(_ sender: Any) {
        
        let Chatmessage = messageField.text ?? ""
        let currentUser = PFUser.current()!
        let chatMessage = PFObject(className: "Message")
        chatMessage["text"] = Chatmessage
        chatMessage["user"] = currentUser
        
        chatMessage.saveInBackground{(success: Bool, error: Error?) in
            if (success){
                print("The message was saved Successfully by \(currentUser)")
                self.messages.append(chatMessage)
                self.tableView.reloadData()
                self.messageField.text = ""
            }
            else if let error = error{
                let errorAlertController = UIAlertController(title: "Problem saving message", message: "Please, Check your internet Connection", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Retry", style: .cancel)
                errorAlertController.addAction(cancelAction)
                self.present(errorAlertController, animated: true)
                print(error.localizedDescription) }
        
        }
        
        
    
        }
        
        
        
    @objc func onTimer() {
        // Add code to be run periodically
        let query = PFQuery(className: "Message")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        query.findObjectsInBackground { (objects:[PFObject]?, error: Error?) -> Void in
            if error==nil{
                print("successfully retrieved \(objects!.count) messages")
                
                self.messages = objects!
                self.tableView.reloadData()
            }
            else{
                print("downloaded chat")
                self.messages = objects!
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        let chatMessage = messages[indexPath.row]
        if let user = chatMessage["user"] as? PFUser {
            // User found! update username label with username
            cell.userLabel.text = user.username!+":"
        } else {
            // No user found, set default username
            cell.userLabel.text = "Unkown User"
        }
        cell.messageLabel.text = (chatMessage["text"] as! String)
        return cell
        
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl)
    {
        loadMessage()
    }
    
    func loadMessage(){
        // construct query
        let query = PFQuery(className: "Message")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        
        // fetch data asynchronously
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                // do something with the array of object returned by the call
                for message in posts{
                    if (message["text"] != nil)
                    {
                        print(message["text"]!)
                    }else{
                        print("no text")
                    }
                }
                self.messages = posts
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
        
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
