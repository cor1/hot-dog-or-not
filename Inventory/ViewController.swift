//
//  ViewController.swift
//  Inventory
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit

class Item:NSObject{
    
    var shortDescription:String?
    var longDescription: String?
    
    init(shortDescription:String,longDescription:String) {
        self.shortDescription = shortDescription
        self.longDescription = longDescription
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate {
    var items = [Item]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Inventory"
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue") {
            let view = segue.destination as! AddViewController
            view.delegate = self
            return
        }
        let view = segue.destination as! EditViewController
        view.delegate = self
        var itemBeingEdited: Int! // a global property
        itemBeingEdited = tableView.indexPathForSelectedRow?.row
        view.passedIndex = itemBeingEdited
        view.passedItem = items[itemBeingEdited]
    }
    
    func userDidEnterInformation(passedObj: Item) {
        items.append(passedObj);
        self.tableView.reloadData()
    }
    
    func userDidEditInformation(passedObj: Item, index: Int) {
        items[index] = passedObj;
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
//            self.items.remove(at: indexPath.row)
            tableView.reloadData()
            actionPerformed(true)
        }
        return UISwipeActionsConfiguration(actions: [destroyAction])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].shortDescription
        cell.detailTextLabel?.text = items[indexPath.row].longDescription
        return cell
    }
    
   
    
    
    


}

