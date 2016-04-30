//
//  ViewController.swift
//  MakeAMeme
//
//  Created by Aaron Phillips on 4/29/16.
//  Copyright © 2016 Aaron Phillips. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    
    var memedImage: UIImage!
    var memes: [Meme]!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default text settings
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor .blackColor(),
            NSForegroundColorAttributeName: UIColor .whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: Float(-3.0)
        ]
        
        // Top Text Field
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = .Center
        topTextField.delegate = self
        
        
        // Bottom Text Field
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = .Center
        bottomTextField.delegate = self
        
    
    }

    override func viewWillAppear(animated: Bool) {
        
        // Disable Camera Button if not Available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if imagePickerView.image == nil {
            shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
        
        // Subscribe to keybaord notifications
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard notifications
        unsubscribeFromKeyboardNotifications()
    }

    
    // Pick an image from Album
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Pick an image from Camera
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Show image in image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imagePickerView.image = image
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Canceled image selection
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Shifting view when keyboard covers text field
    
    // Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }
    // Unsubscribe from keybaord notitfications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    // Get and use keyboard height
    
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
        view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    // Clear text when clicked
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
                textField.text = ""
            }
    }
    // Return button hides keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
        
    func save() {
        
        _ = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        UIGraphicsBeginImageContext(view.frame.size)
        self.view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        
        // memed image to activity view
        memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage!],
                                                  applicationActivities: nil)
        
        // Save image to shared
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
}

