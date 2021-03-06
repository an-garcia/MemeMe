//
//  ViewController.swift
//  MemeMe
//
//  Created by xengar on 2017-11-08.
//  Copyright © 2017 xengar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var ImagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton : UIBarButtonItem!
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBotton : UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    
    // MARK: Memeber variables
    let editTopDelegate = EditTextFieldDelegate()
    let editBottomDelegate = EditTextFieldDelegate()
    var meme: Meme = Meme()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // disable camera button if it's not available
        self.cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        // disable the share button if there it's no image
        self.shareButton.isEnabled = false
        
        // set text fields
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.red,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3.0]
        
        
        self.textTop.text = "TOP"
        self.textTop.textAlignment = .center
        self.textTop.delegate = self.editTopDelegate
        self.textTop.defaultTextAttributes = memeTextAttributes
        self.textBotton.text = "BOTTOM"
        self.textBotton.textAlignment = .center
        self.textBotton.delegate = self.editBottomDelegate
        self.textBotton.defaultTextAttributes = memeTextAttributes
    }

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(pickerController, animated: true, completion: nil)
    }
    
    
    // MARK: ImagePicker cancel dialog
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil) // dismiss dialog
    }
    
    // MARK: The user selected an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage // get image
        
        self.ImagePickerView.contentMode = .center // scale type
        self.ImagePickerView.image = chosenImage // set image to view
        dismiss(animated:true, completion: nil) // dismiss dialog
        
        // enable the share button
        self.shareButton.isEnabled = true
    }
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Initialize a Meme object
    func save() {
        
        let memedImage = generateMemedImage()
        // Create the meme
        let meme = Meme(topText: textTop.text!, bottomText: textBotton.text!, originalImage: ImagePickerView.image!, memedImage: memedImage)
        self.meme = meme
        
        // Add it to the memes array in the Application Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    

    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.toolBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.toolBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        return memedImage
    }
    
    
    // MARK: Share Meme
    @IBAction func shareMeme(_ sender: Any) {
        // save the meme
        save()
        // save meme image to photo library
        UIImageWriteToSavedPhotosAlbum(self.meme.memedImage!, self, #selector(addImageToLibrary(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    
    //MARK: - Add image to Library
    @objc func addImageToLibrary(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}

