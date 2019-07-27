//
//  ViewController.swift
//  Final
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseStorage

// create object to pass our items around the app
class Item:NSObject{
    
    var shortDescription:String?
    var tags: [String]
    var image: UIImage
    var index: Int
    
    init(shortDescription:String, tags:[String], image: UIImage, index: Int) {
        self.shortDescription = shortDescription
        self.tags = tags
        self.image = image
        self.index = index
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {
    var items = [Item]()
    var currentDownloadUrl = ""

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Hot Dog or Not"
        //initialize firebase
        let db = Firestore.firestore()
        //get the list from firebase
        db.collection("list").order(by: "index").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                var index = 0;
                // loop over each document in firestore and get the image for it
                for document in querySnapshot!.documents {
                    let islandRef = storageRef.child("list/" + String(index))
                    islandRef.getData(maxSize: 1 * 1024 * 1024 * 10) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            let image = UIImage(data: data!)
                            //create an item with the firestore document info and add it to our items array
                            self.items.append(Item(shortDescription: document.data()["shortDescription"]! as! String, tags: document.data()["tags"]! as! [String], image: image!, index: document.data()["index"]! as! Int))
                            self.items = self.items.sorted(by: { $0.index < $1.index })
                            self.tableView.reloadData()
                        }
                    }
                    index += 1
                }
            }
        }
        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }
    
    // navigate segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue") {
            let view = segue.destination as! AddViewController
            view.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = "Items"
            navigationItem.backBarButtonItem = backItem
            return
        }
        let view = segue.destination as! EditViewController
        view.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = "Items"
        navigationItem.backBarButtonItem = backItem
        var itemBeingEdited: Int! // a global property
        itemBeingEdited = tableView.indexPathForSelectedRow?.row
        view.passedIndex = itemBeingEdited
        view.passedItem = items[itemBeingEdited]
    }
    
    func userDidEnterInformation(passedObj: Item) {
        items.append(passedObj);
        //save the new item to the db
        saveToDatabase(item: passedObj, index: items.count-1)
        self.tableView.reloadData()
    }
    
    func userDidEditInformation(passedObj: Item, index: Int) {
        items[index] = passedObj;
        //save the edited item to the db
        saveToDatabase(item: passedObj, index: index)
        self.tableView.reloadData()
    }
    
    
    ////////table stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
        UISwipeActionsConfiguration? {
        let destroyAction = UIContextualAction(style: .destructive, title: "Delete") { (action:UIContextualAction, sourceView:UIView, actionPerformed:(Bool)-> Void) in
            let db = Firestore.firestore()
            //remove the document from firebase
            db.collection("list").document(String(self.items[indexPath.row].index)).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.items.remove(at: indexPath.row)
            tableView.reloadData()
            actionPerformed(true)
        }
        return UISwipeActionsConfiguration(actions: [destroyAction])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].shortDescription
        if (items[indexPath.row].tags.contains("Hot dog")) {
            cell.textLabel?.textColor = UIColor.green
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        //give thumbnail image
        cell.imageView?.image = items[indexPath.row].image
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    
    func saveToDatabase(item: Item, index: Int) {
        var data = NSData()
        let img1 = item.image
        let db = Firestore.firestore()
        //get image data in jpeg
        data = img1.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let filePath = "list/" + String(index)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child(filePath)
        imageRef.putData(data as Data, metadata: metaData){(metaData,error) in
            // download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                //add a new document to firebase and give it data such as tags etc
                db.collection("list").document(String(index)).setData([
                    "shortDescription" : item.shortDescription!,
                    "tags": item.tags,
                    "image": downloadURL.absoluteString,
                    "index": index
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added!!!!")
                    }
                }
            }
        }
    }
}

