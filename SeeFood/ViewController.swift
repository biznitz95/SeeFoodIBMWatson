//
//  ViewController.swift
//  SeeFood
//
//  Created by Bizet Rodriguez on 9/25/18.
//  Copyright © 2018 Bizet Rodriguez. All rights reserved.
//
// Completed 09/25/18

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // IBM Watson required info
    let apiKey = "EmY6sDZ6pk8j7bQLQ2qn2AtEspg6P2IA-5MAorq_bmwj"
    let version = "2018-09-25"
    
    // IBOutlests for imageView, camera and search
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    // Camera delegate and
    let imagePicker = UIImagePickerController()
    
    var classificationResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        disabled()
        SVProgressHUD.show()
        
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError("Error downcasting image to UIImage.")}
        
        imageView.image = userPickedImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
        
        let imageData = userPickedImage.jpegData(compressionQuality: 0.01)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("TempImage.jpg")

        try? imageData?.write(to: fileURL, options: [])

        visualRecognition.classify(imagesFile: fileURL, url: nil, threshold: nil, owners: nil, classifierIDs: nil, acceptLanguage: nil, headers: nil, failure: { (error) in
            print("Error classifying image, \(error)")
        }) { (classifiedImages) in
            let classes = classifiedImages.images.first!.classifiers.first!.classes
            
            self.classificationResults.removeAll()
            self.classificationResults = classes.map(){$0.className}
            
            DispatchQueue.main.async {
                self.enabled()
                SVProgressHUD.dismiss()
            }
            
            if self.classificationResults.contains("hotdog") {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Not A Hotdog!"
                }
            }
        }
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func searchPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func enabled() {
        cameraButton.isEnabled = true
        searchButton.isEnabled = true
    }
    
    func disabled() {
        cameraButton.isEnabled = false
        searchButton.isEnabled = false
    }
}

