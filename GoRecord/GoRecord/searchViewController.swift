//
//  searchViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 2/20/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import CoreData
import ReactiveCocoa
import ReactiveSwift



class searchViewController: UITableViewController, SlideMenuDelegate {
    

    @IBOutlet weak var searchFieldOutlet: UITextField!
    
    var appDel = (UIApplication.shared.delegate as! AppDelegate)
    
    
    
    var songs = ["MakeDamnSure", "Bittersweet Symphony", "HYFR"]
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You clicked on a cell at index \(indexPath.row)")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell") as! songCell
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func searchListen(){
//        let searchString = searchFieldOutlet.reactive.continuousTextValues
//        let searchResults = searchString.flatMap(.latest){
//            (query:String?)-> SignalProducer<(Data, URLResponse), Error> in let request = self.makeSearchRequest(escapedQuery: query)
//            return URLSession.shared.reactive.data(with: request)
//        }
//    }
    
    
    
    
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
    

    
    
    
}
