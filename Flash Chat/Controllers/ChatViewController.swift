//
//  ChatViewController.swift
//  Flash Chat
//
//  Created by Adam Daris Ryadhi on 26/09/24.
//

import UIKit
import FirebaseAuth
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    let db = Firestore.firestore()
    
    var message: [Message] = [
        Message(sender: "1@2.com", body: "Hey!"),
        Message(sender: "1@2.com", body: "Hey!"),
        Message(sender: "1@2.com", body: "Hey!")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        title = Key.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: Key.cellNibName, bundle: nil), forCellReuseIdentifier: Key.cellIdentifier)
        
        loadMessage()
    }
    
    func loadMessage() {
        message = []
        
        db.collection(Key.FStore.collectionName)
            .order(by: Key.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            
            self.message = []
            
            if let e = error {
                print(e)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[Key.FStore.senderField] as? String, let messageBody = data[Key.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.message.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                let indexPath = IndexPath(row: self.message.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(Key.FStore.collectionName).addDocument(data: [
                Key.FStore.senderField: messageSender,
                Key.FStore.bodyField: messageBody,
                Key.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print(e)
                } else {
                    print("Success")
                    
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = message[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Key.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: Key.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: Key.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: Key.BrandColors.purple)
            cell.label.textColor = UIColor(named: Key.BrandColors.lightPurple)
        }
        
        return cell
    }
}
