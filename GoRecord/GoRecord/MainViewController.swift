//
//  ViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 2/19/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

//Change the http requests for each IP address.

import UIKit
import CoreData
import Alamofire



class MainViewController: UIViewController {
    
    //Variables
    
    var userArr = [User]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var flag = false
    
    var appDel = (UIApplication.shared.delegate as! AppDelegate)
    
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    @IBAction func rememberMeButton(_ sender: UIButton) {
       self.flag = true
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        if self.flag == true{
            for user in self.userArr{
                if user.email == self.loginField.text! {
                    user.logged = true
                    
                    if self.context.hasChanges {
                        do {
                            try self.context.save()
                            print("user will be remembered")
                        } catch {
                            print("\(error)")
                        }
                    }
                }
            }
        }
        validateLogin(email: self.loginField.text!, password: self.passField.text!)
    }

    
    @IBAction func registerButton(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "registerViewOne") as! registerViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // fetchAllUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchAllUsers(){
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            self.userArr = try context.fetch(userRequest) as! [User]
            for user in userArr{
                if user.logged == true{
                    
                    let appDel = (UIApplication.shared).delegate as! AppDelegate
                    appDel.user = user.email!
                    
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeView") as! homeViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }
            }
        } catch {
            print("\(error)")
        }
    }
    
    func validateLogin(email:String, password:String){
        let parameters = ["email":"\(email)", "password": "\(password)"]
        Alamofire.request("\(appDel.url)/login", method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
                case .success:
                    
                    let appDel = (UIApplication.shared).delegate as! AppDelegate
                    appDel.user = email
                    appDel.currentArtist.artist_id = email
                    
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeView") as! homeViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                
                
                case .failure(let error):
                    print(error)
                
                
                
                
            }
        }
    }


}

