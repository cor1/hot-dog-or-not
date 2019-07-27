//
//  AddViewController.swift
//  Inventory
//
//  Created by Kyle McArthur on 6/8/19.
//  Copyright © 2019 Kyle McArthur. All rights reserved.
//

import UIKit
import FirebaseMLVision
// protocol used for sending data back
protocol DataEnteredDelegate: class {
    func userDidEnterInformation(passedObj: Item)
    func userDidEditInformation(passedObj: Item, index: Int)
}

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: DataEnteredDelegate? = nil
    
    @IBOutlet weak var shortDescription: UITextField!
    @IBOutlet weak var imageCont: UIImageView!
    var labelArr = [String]()

    @IBAction func addImage(_ sender: UIButton) {
        showAlert()
    }
    
    @IBOutlet weak var heading: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add New Item"

        let save = UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save        
    }
    
    @objc func saveItem() {
        //bail if insufficient info is entered
        if ((shortDescription.text ?? "").isEmpty || imageCont.image === nil) {
            self.navigationController?.popViewController(animated: true)
            return
        }
        //save items back to main view
        let newObj = Item(shortDescription: shortDescription.text!, tags: labelArr, image: imageCont.image!, index: 0)
        delegate?.userDidEnterInformation(passedObj: newObj)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    func showAlert() {
        //show options to get images from device.
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //get image from source type
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //get the selected image so we can run ml kit and cloud vision on it.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.labelArr = []
        imageCont.image = selectedImage
        let image = VisionImage(image: selectedImage)
        //setup vision and the labeler
        let labeler = Vision.vision().onDeviceImageLabeler()
        //process the image and get labels
        labeler.process(image) { labels, error in
            guard error == nil, let labels = labels else { return }
            //append labels into array for storage in firebase
            for label in labels {
                self.labelArr.append(label.text)
            }
            //display text if it was a hot dog or not and color it
            if (self.labelArr.contains("Hot dog")) {
                self.heading.text = "HOT DOG!"
                self.heading.textColor = UIColor.green
            } else {
                self.heading.text = "NOT HOT DOG!"
                self.heading.textColor = UIColor.red
            }
        }
        dismiss(animated: true, completion: nil)
    }


}
