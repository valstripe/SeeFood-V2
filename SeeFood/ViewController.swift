//
//  ViewController.swift
//  SeeFood
//
//  Created by Valentinas Stripeika on 1/23/18.
//  Copyright © 2018 Valentinas Stripeika. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "406e59b1e929947e3db8a59f2c7e7d7da1cb025d"
    let version = "2017-01-24"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            cameraButton.isEnabled = false
            SVProgressHUD.show()
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not a Hotdog!"
                    }
                    
                }
                
            })
        } else {
            print("There was an error picking the image")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

