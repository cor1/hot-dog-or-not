//
//  EditViewController.swift
//  Inventory
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    var passedItem: Item!
    var passedIndex = 0
    @IBOutlet weak var shortDescription: UITextField!
    @IBOutlet weak var imageCont: UIImageView!
    @IBOutlet weak var heading: UILabel!
    weak var delegate: DataEnteredDelegate? = nil
    var labelArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Item"
        let save = UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
        // Do any additional setup after loading the view.
        shortDescription?.text = passedItem.shortDescription
        imageCont?.image = passedItem.image
        labelArr = passedItem.tags
        //show label if its a hot dog, they are allowed to edit only the title
        if (self.labelArr.contains("Hot dog")) {
            self.heading.text = "HOT DOG!"
            self.heading.textColor = UIColor.green
        } else {
            self.heading.text = "NOT HOT DOG!"
            self.heading.textColor = UIColor.red
        }
    }
    
    @objc func saveItem() {
        //save items back to main view
        if (shortDescription.text ?? "").isEmpty {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let newObj = Item(shortDescription: shortDescription.text!, tags: labelArr, image: imageCont.image!, index: passedIndex)
        delegate?.userDidEditInformation(passedObj: newObj, index: passedIndex)
        self.navigationController?.popViewController(animated: true)
    }

}
