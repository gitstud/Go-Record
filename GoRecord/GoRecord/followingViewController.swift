//
//  followingViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 3/2/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class followingViewController: UITableViewController, SlideMenuDelegate {
    
    //Songs Array
    var artists = [Artist]()
    let appDel = (UIApplication.shared.delegate as! AppDelegate)
    
    var following = String()
    var follower = Bool()
    
    
    
    @IBOutlet weak var followLabel: UILabel!
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    //Did select song at index
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! profileViewController
            self.appDel.currentArtist.artist_id = self.artists[indexPath.row].artist_id
            self.present(vc, animated: false, completion: nil)
        }

    }
    
    
    
    //cell for row at index
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! followerCell
        cell.followerName.text = artists[indexPath.row].name
        cell.followerPlayCount.text = "Plays: \(artists[indexPath.row].plays)"
        cell.followerTrackCount.text = "Tracks: \(artists[indexPath.row].uploads.count)"
        cell.followerFollowCount.text = "Followers: \(artists[indexPath.row].followers.count)"
        
        Alamofire.request("\(appDel.url)/profile_pic/\(artists[indexPath.row].email)").responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                self.artists[indexPath.row].pic = image as UIImage
                cell.followerImage.image = image as UIImage
                
            }
        }
        
       
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getArtists()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getArtists(){
        
        if (self.follower == false) {
            
            self.followLabel.text = "Following"
        
            Alamofire.request("\(appDel.url)/following/\(self.appDel.user)", method: .get).responseJSON { response in
                switch response.result {
                
                    case .success:
                        if let result = response.result.value as? Array<Dictionary<AnyHashable,AnyHashable>> {
                            let JSON = result
                            for s in JSON{
                                var featuredSong = Artist()
                                featuredSong.artist_id = s["email"] as! String
                                featuredSong.name = s["name"]! as! String
                                featuredSong.uploads = s["uploads"]! as! [String]
                                featuredSong.email = s["email"]! as! String
                                featuredSong.name = s["name"]! as! String
                                featuredSong.plays = s["plays"]! as! Int
                                featuredSong.tags = s["tags"]! as! [String]
                                featuredSong.following = s["following"] as! [String]
                                featuredSong.followers = s["followers"] as! [String]
                                featuredSong.location = s["location"] as! String
                                featuredSong.likes = s["likes"]! as! [String]
                                featuredSong.imagePath = (s["imagePath"]! as? String)!
                                featuredSong.pageViews = s["pageViews"]! as! Int
                                self.artists.append(featuredSong)
                            }
                            self.tableView.reloadData()
                            self.followLabel.text = self.followLabel.text! + " \(self.artists.count)"
                            return
                        }
                        break
                
                    case .failure(let error):
                        print(error)
                        break
                }
            }
            
        } else if (self.follower == true) {
            
            self.followLabel.text = "Followers"
            
            Alamofire.request("\(appDel.url)/followers/\(self.appDel.user)", method: .get).responseJSON { response in
                switch response.result {
                    
                case .success:
                    if let result = response.result.value as? Array<Dictionary<AnyHashable,AnyHashable>> {
                        let JSON = result
                        print(JSON)
                        for s in JSON{
                            print("$$$$$$$$$$$$$$")
                            var featuredSong = Artist()
                            featuredSong.artist_id = s["email"] as! String
                            featuredSong.name = s["name"]! as! String
                            featuredSong.uploads = s["uploads"]! as! [String]
                            featuredSong.email = s["email"]! as! String
                            featuredSong.name = s["name"]! as! String
                            featuredSong.plays = s["plays"]! as! Int
                            featuredSong.tags = s["tags"]! as! [String]
                            featuredSong.following = s["following"] as! [String]
                            featuredSong.followers = s["followers"] as! [String]
                            featuredSong.location = s["location"] as! String
                            featuredSong.likes = s["likes"]! as! [String]
                            featuredSong.imagePath = (s["imagePath"]! as? String)!
                            featuredSong.pageViews = s["pageViews"]! as! Int
                            print(featuredSong)
                            self.artists.append(featuredSong)
                        }
                        self.followLabel.text = self.followLabel.text! + " \(self.artists.count)"
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
