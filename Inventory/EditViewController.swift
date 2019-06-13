//
//  EditViewController.swift
//  Inventory
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    var passedItem = Item(shortDescription: "", longDescription: "")
    var passedIndex = 0
    @IBOutlet weak var shortDescription: UITextField!
    @IBOutlet weak var longDescription: UITextView!
    weak var delegate: DataEnteredDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Item"
        let save = UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
        // Do any additional setup after loading the view.
        shortDescription?.text = passedItem.shortDescription
        longDescription?.text = passedItem.longDescription
    }
    
    @objc func saveItem() {
        if (shortDescription.text ?? "").isEmpty && (longDescription.text ?? "").isEmpty {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let newObj = Item(shortDescription: shortDescription.text!, longDescription: longDescription.text!)
        delegate?.userDidEditInformation(passedObj: newObj, index: passedIndex)
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
