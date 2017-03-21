//
//  featuredViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 2/19/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class featuredViewController: UITableViewController, SlideMenuDelegate {

    //Songs Array
    var songs = [Song]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDel = (UIApplication.shared.delegate as! AppDelegate)
    

    //Did select song at index
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        //get audio function
        getAudio(songPath: songs[indexPath.row], songIndex: indexPath.row)
    }
    
    
    
    //cell for row at index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell") as! songCell
        cell.songTitle.text = songs[indexPath.row].name
        cell.songArtist.text = songs[indexPath.row].artist
        
        Alamofire.request("\(appDel.url)/imageFor/\(songs[indexPath.row].id)").responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                self.songs[indexPath.row].pic = image as UIImage
                cell.songArt.image = image as UIImage
            }
        }
        
        
//        let imageFile = songs[indexPath.row].image
//        let url = URL(fileURLWithPath: imageFile)
//        
////        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        
    
        // Do any additional setup after loading the view, typically from a nib.
        getFeatures()
        tableView.reloadData()
    }
    


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getFeatures(){
        
        Alamofire.request("\(appDel.url)/featured", method: .get).responseJSON { response in
            switch response.result {
                
            case .success:
                if let result = response.result.value as? Array<Dictionary<AnyHashable,AnyHashable>> {
                    let JSON = result
                    for s in JSON{
                        var featuredSong = Song()
                        featuredSong.artist = s["artist"]! as! String
                        featuredSong.artist_id = s["artist_id"]! as! String
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
    
    
    
    func getAudio(songPath:Song, songIndex: Int){
        
        let id = songPath.id
        if let audioUrl = URL(string: "\(appDel.url)/requestAudio/\(id)"){
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationURL.path){

                print("the file already exists at path")
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "songView") as! songViewController
                   
                    self.appDel.currentSong = songPath
                    self.appDel.currentArtist.artist_id = songPath.artist_id
                    vc.audio = destinationURL
                   
                    self.appDel.currentArtist.artist_id = songPath.artist_id
                    
                    self.present(vc, animated: true, completion: nil)
            
                }
            } else {
                print("downloading from server")
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: {(location, response, error)-> Void in
                    guard let location = location, error == nil else {return}
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        print("file moved to documents folder")
                        print(destinationURL)
                        
                        DispatchQueue.main.async {
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "songView") as! songViewController
                        
                                                self.appDel.currentSong = songPath
                                                vc.audio = destinationURL
                            
                            
                                                self.appDel.currentArtist.artist_id = songPath.artist_id
                            
                                                self.present(vc, animated: true, completion: nil)
                                                
                                            }

                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            
            }
        }
    }

    
    // Slide Menu
    
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
                vc.following = self.appDel.user
                vc.follower = false
                self.present(vc, animated: false, completion: nil)
            }
            
           
            
            break
        case 4:
            print("Followers\n", terminator: "")
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Followers") as! followingViewController
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
    

    
    
    
//end
    

    
    
}
