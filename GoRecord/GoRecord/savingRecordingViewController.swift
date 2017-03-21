//
//  savingRecordingViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 3/3/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import Alamofire

class saveRecordingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    var audioFile:URL!
    var audioFileName:String!
    var audioFileLength:String!
    
    var imageAdded:imageAddedDelegate?
    
    
    @IBOutlet weak var titleInput: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func useCamera(_ sender: UIButton) {
        print("helloworld")
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = true
        self.present(image, animated: true)
        {
            print("sdf")
        }
    }
    
    
    
    @IBAction func uploadAction(_ sender: UIButton) {
        
        var imageURL:URL!
        
        if self.imageView.image != nil {
            let image = self.imageView.image
            let imageFile = getDocumentsDirectory().appendingPathComponent("copy.png").path
            imageURL = URL(fileURLWithPath: imageFile)
            let data = UIImagePNGRepresentation(image!)! as NSData
            try? data.write(to: imageURL)
            print("imageSaved")
        }
        

        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageURL, withName:"imageFile")
                multipartFormData.append(self.audioFile, withName:"audioFile")
            },
            to: "\(appDel.url)/iosUpload/\(self.appDel.user)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! profileViewController
                                self.appDel.currentArtist.artist_id = self.appDel.user
                                self.present(vc, animated: false, completion: nil)
                            }
                    }
                    case .failure(let encodingError):
                        print(encodingError)
                }
            }
        )
        
        
        
        
    }
    
    
    
    
    
    
    // image picker controller delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : Any]){
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            print(image)
            
            imageView.image = image
        }
        else {
            print("WTF")
        }
        print("kjsdgkjsdg")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func getDocumentsDirectory()->URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
}
