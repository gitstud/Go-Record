//
//  registerViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 2/19/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import CoreData
import Alamofire



class registerViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDel = (UIApplication.shared.delegate as! AppDelegate)

    
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPhone: UITextField!
    @IBOutlet weak var userPass: UITextField!
    @IBOutlet weak var userCPass: UITextField!

    @IBAction func registerButton(_ sender: UIButton) {
        
        //Save User to Core Data
        
        
        if let email = self.userEmail.text {
            if email != "" {
                if let name = self.userPhone.text {
                    if name != "" {
                        if let password = self.userPass.text {
                            if password.characters.count > 3{
                                if let cPass = self.userCPass.text{
                                    if cPass == password {
                                        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
                                
                                        newUser.email = email
                                        newUser.password = password
                                
                                        if self.context.hasChanges {
                                    
                                            do{
                                                try self.context.save()
                                                print("Saved User to core Data")
                                        
                                        
                                        //Save User To Server
                                        
                                                let parameters = ["email": "\(email)", "password": "\(password)",
                                                "name":"\(name)"]
                                                Alamofire.request("\(appDel.url)/newUser", method: .post, parameters: parameters).responseJSON { response in
                                                    print("Response JSON: \(String(describing: response.result.value))!")
                                                    
                                                    self.appDel.user = email
                                                    
                                                    DispatchQueue.main.async {
                                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeView") as!                 homeViewController
                                                        self.present(vc, animated: true, completion: nil)
                                                    }
                                                    
                                                }
                                        
                                            } catch {
                                                print("\(error)")
                                            }
                                        }
                                
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        

    }

    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
