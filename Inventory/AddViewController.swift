//
//  AddViewController.swift
//  Inventory
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit

// protocol used for sending data back
protocol DataEnteredDelegate: class {
    func userDidEnterInformation(passedObj: Item)
    func userDidEditInformation(passedObj: Item, index: Int)
}

class AddViewController: UIViewController {

    weak var delegate: DataEnteredDelegate? = nil
    
    @IBOutlet weak var shortDescription: UITextField!
    @IBOutlet weak var longDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add New Item"

        let save = UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
        
        // Do any additional setup after loading the view.
    }
    
    @objc func saveItem() {
        if (shortDescription.text ?? "").isEmpty && (longDescription.text ?? "").isEmpty {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let newObj = Item(shortDescription: shortDescription.text!, longDescription: longDescription.text!)
        delegate?.userDidEnterInformation(passedObj: newObj)
        
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
