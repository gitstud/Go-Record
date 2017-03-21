//
//  profileViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 3/1/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import Alamofire



class profileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SlideMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var songs = [Song]()
    var likes = [Song]()
    var artist = Artist()
    
  
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBOutlet weak var nameOutlet: UILabel!
    
    @IBOutlet weak var emailOutlet: UILabel!
    
    @IBOutlet weak var locationOutlet: UILabel!
    

    @IBOutlet weak var newRecordOutlet: UIButton!
    @IBAction func newRecord(_ sender: UIButton) {
    }
    
    
    
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    @IBAction func followButton(_ sender: UIButton) {
        
        if (self.appDel.user != self.appDel.currentArtist.artist_id){
        
        Alamofire.request("\(appDel.url)/newFollower/\(self.appDel.user)/\(self.appDel.currentArtist.artist_id)", method: .get).responseJSON { response in
            switch response.result {
                
            case .success:
                if let result = response.result.value {
                    print(result)
                }
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
        }
        
    }
    
    // image picker controller delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : Any]){
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            print(image)
            
            profileImage.image = image
            
            var imageURL:URL!
            
            if self.profileImage.image != nil {
                let image = self.profileImage.image
                let imageFile = getDocumentsDirectory().appendingPathComponent("copy.png").path
                imageURL = URL(fileURLWithPath: imageFile)
                let data = UIImagePNGRepresentation(image!)! as NSData
                try? data.write(to: imageURL)
                print("imageSent")
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(imageURL, withName:"imageFile")
                },
                    to: "\(appDel.url)/iosProfileImage/\(self.appDel.user)",
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                debugPrint(response)
                                
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                }
                )

            }
            
            
        }
        else {
            print("WTF")
        }
        print("kjsdgkjsdg")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func getFeatures(p: String){
        
        Alamofire.request("\(appDel.url)/profile_music/\(p)", method: .get).responseJSON { response in
            switch response.result {
                
            case .success:
                if let result = response.result.value as? Array<Dictionary<AnyHashable,AnyHashable>> {
                    let JSON = result
                    for s in JSON{
                        var featuredSong = Song()
                        featuredSong.artist = s["artist"]! as! String
                        featuredSong.createdAt = s["createdAt"]! as! NSDate
                        featuredSong.filePath = s["filePath"]! as! String
                        featuredSong.name = s["name"]! as! String
                        featuredSong.plays = s["plays"]! as! Int
                        featuredSong.likes = s["likes"]! as! Int
                        featuredSong.id = s["_id"]! as! String
                        featuredSong.image = (s["imagePath"]! as? String)!
                        self.songs.append(featuredSong)
                    }
                    self.tableView.reloadData()
                    return
                }
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    
    func getArtist(){
        print("&&&&&&&&&&&&&", self.appDel.currentArtist.artist_id)
        Alamofire.request("\(appDel.url)/artist/\(self.appDel.currentArtist.artist_id)", method: .get).responseJSON { response in
            switch response.result {
                
            case .success:
                if let result = response.result.value as? Dictionary<AnyHashable,AnyHashable> {
                    let JSON = result
                    
                    self.artist.artist_id = JSON["email"]! as! String
                    self.artist.name = JSON["name"]! as! String
                    self.artist.uploads = JSON["uploads"]! as! [String]
                    self.artist.likes = JSON["likes"]! as! [String]
                    self.artist.plays = JSON["plays"]! as! Int
                    self.artist.tags = JSON["tags"]! as! [String]
                    self.artist.following = JSON["following"]! as! [String]
                    self.artist.followers = JSON["followers"]! as! [String]
                    self.artist.location = JSON["location"]! as! String
                    self.artist.imagePath = JSON["imagePath"]! as! String
                    self.artist.blocked = JSON["blocked"]! as! [String]
                    self.artist.pageViews = JSON["pageViews"]! as! Int
                    self.artist.email = JSON["email"]! as! String
                    
                    print("$$$$$$ self artist $$$$$$$$$",self.artist)
                    self.appDel.currentArtist.artist_id = self.artist.artist_id
                    self.nameOutlet.text = self.artist.name
                    self.emailOutlet.text = self.artist.email
                    self.locationOutlet.text = self.artist.location
                   self.getFeatures(p: self.artist.email)
                    
                    
                    Alamofire.request("\(self.appDel.url)/getProfileImage/\(self.artist.artist_id)").responseImage { response in
                        debugPrint(response)
                        
                        print(response.request!)
                        print(response.result)
                        
                        if let image = response.result.value {
                            self.profileImage.image = image as UIImage
                        }
                    }
                    
                    
                }
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    
    
    //Did select song at index
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //get audio function
        getAudio(songPath: songs[indexPath.row], songIndex: indexPath.row)
    }
    
    
    
    //cell for row at index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! profileSongCell
        cell.profileCellTitle.text = songs[indexPath.row].name
        cell.profileCellArtist.text = songs[indexPath.row].artist
        
        Alamofire.request("\(appDel.url)/imageFor/\(songs[indexPath.row].id)").responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.result)
            
            if let image = response.result.value {
                self.songs[indexPath.row].pic = image as UIImage
                cell.profileCellArt.image = image as UIImage
            }
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    
    
    func getAudio(songPath:Song, songIndex: Int){
        
        let id = songPath.id
        if let audioUrl = URL(string: "\(appDel.url)/requestAudio/\(id)"){
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationURL.path){
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "songView") as! songViewController
                    
                    self.appDel.currentSong = songPath
                    vc.audio = destinationURL
                    
                    self.present(vc, animated: true, completion: nil)
                    
                }
            } else {
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: {(location, response, error)-> Void in
                    guard let location = location, error == nil else {return}
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "songView") as! songViewController
                            print(self.appDel.currentArtist.artist_id, "####")
                            print(self.appDel.currentSong.artist_id, "####")
                            self.appDel.currentSong = songPath
                            vc.audio = destinationURL
                            
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
                
            }
        }
    }
    
    
    
    
    @IBAction func changeImageButton(_ sender: UIButton) {
        
        print("helloworld")
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = true
        self.present(image, animated: true)
        {
            print("sdf")
            print(image)
            
            
            
        }
        
        
    }
    
    @IBOutlet weak var changeImageOutlet: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.getFeatures(p: self.artist.email)
        
   
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (self.appDel.user == self.appDel.currentArtist.artist_id){
            self.followButtonOutlet.isHidden = true
            self.changeImageOutlet.isHidden = false
            
        }
        if (self.appDel.user != self.appDel.currentArtist.artist_id){
            self.newRecordOutlet.removeFromSuperview()
        }
        
       
       getArtist()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func slideMenuItemSelectedAtIndex(_ index: Int) {
        
        print("View Controller is : \(self) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n")
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeView") as! homeViewController
                self.appDel.currentArtist.artist_id = self.appDel.user
                self.present(vc, animated: false, completion: nil)
            }
            
            
        case 1:
            print("Profile\n", terminator: "")
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! profileViewController
                self.appDel.currentArtist.artist_id = self.appDel.user
                self.present(vc, animated: false, completion: nil)
            }
            
            break
        case 2:
            print("Messages\n", terminator: "")
            
            
            
            
            
            break
        case 3:
            print("Following\n", terminator: "")
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Followers") as! followingViewController
                self.appDel.currentArtist.artist_id = self.appDel.user
                vc.following = self.appDel.user
                vc.follower = false
                self.present(vc, animated: false, completion: nil)
            }
            
            
            
            break
        case 4:
            print("Followers\n", terminator: "")
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Followers") as! followingViewController
                self.appDel.currentArtist.artist_id = self.appDel.user

                vc.following = self.appDel.user
                vc.follower = true
                self.present(vc, animated: false, completion: nil)
            }
            break
        case 5:
            print("Stats\n", terminator: "")
            
            
            
            break
        case 6:
            print("Settings\n", terminator: "")
            
            
            
            break
        case 7:
            print("LogOut\n", terminator: "")
            
            
            
            break
        default:
            print("default\n", terminator: "")
        }
    }

    
    
    
    
    
    @IBAction func onSlideMenuButtonPressed(_ sender: UIButton) {
        
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
        
    }
    

    
    func getDocumentsDirectory()->URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
 
    
    
}
