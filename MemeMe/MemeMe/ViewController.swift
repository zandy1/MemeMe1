//
//  ViewController.swift
//  MemeMe
//
//  Created by Alexander Brown on 2/1/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var cameraButton: UIBarItem!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageSourceToolbar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -4.0
    ]
    
    struct Meme {
        let topText: String!
        let bottomText: String!
        let originalmage: UIImage!
        let memedImage: UIImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(tf: self.textField1, text: "TOP")
        setupTextField(tf: self.textField2, text: "BOTTOM")
        }

        func setupTextField(tf: UITextField, text: String) {
            tf.defaultTextAttributes = memeTextAttributes
            tf.text = text
            tf.textColor = UIColor.white
            tf.tintColor = UIColor.white
            tf.textAlignment = .center
            tf.text = text
            tf.delegate = self
        }
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField1.delegate = self
        self.textField2.delegate = self
    } */

    @IBAction func pickAnImage(_ sender:Any) {
        presentPickerViewController(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        presentPickerViewController(source: .camera)
        }
    
    func presentPickerViewController(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
                    imagePickerView.image = image
                }
        self.shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.clearsOnBeginEditing = true
        textField.defaultTextAttributes = memeTextAttributes
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        self.shareButton.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if (self.textField2.isEditing) {
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }
    
    func save() {
            // Create the meme
        let meme = Meme(topText: textField1.text!, bottomText: textField2.text!, originalmage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {

        // TODO: Hide toolbar and navbar
        self.shareButton.isHidden = true
        self.imageSourceToolbar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // TODO: Show toolbar and navbar
        self.shareButton.isHidden = false
        self.imageSourceToolbar.isHidden = false

        return memedImage
    }
    
    @IBAction func shareMeme() {
        let items = [generateMemedImage()]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityViewController, animated: true)
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("saved")
                self.save()
            }
            else {
              print("not saved")
            }
        }
    }
}

