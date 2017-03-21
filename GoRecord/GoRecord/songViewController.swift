//
//  songViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 2/26/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire


class songViewController: UIViewController {
    
    var player: AVAudioPlayer?
    
    var audio:URL!
    
    var audioInput: TempiAudioInput!
    var spectralView: SpectralView!
    
    
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var songArtwork: UIImageView!
    
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var songArtistText: UIButton!
    
    @IBOutlet weak var spectralViewOutlet: UIView!
    
    @IBAction func songArtist(_ sender: UIButton) {
        
        if player != nil {
            if (player?.isPlaying)! {
                player?.stop()
            }
        }
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! profileViewController
            print("$$$$$$$$$", self.appDel.currentArtist.artist_id)
            self.present(vc, animated: false, completion: nil)
        
        }
    }
    
    let likes = (UIApplication.shared.delegate as! AppDelegate).likes
    
   
    
    @IBAction func backButton(_ sender: UIButton) {
        if player != nil {
            if (player?.isPlaying)! {
                player?.stop()
                audioInput.stopRecording()
            }
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func likeButton(_ sender: UIButton) {
        //like button code
        Alamofire.request("\(appDel.url)/likeSong/\(self.appDel.user)/\(self.appDel.currentSong.id)", method: .get).responseJSON { response in
            switch response.result {
            case .success:
                print("Successful Like")
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.songTitle.text = self.appDel.currentSong.name
        self.songArtistText.setTitle("\(self.appDel.currentSong.artist)", for: .normal)
        self.songArtwork.image = self.appDel.currentSong.pic
        
        self.songArtwork.isUserInteractionEnabled = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(songViewController.playPause(tapGestureRecognizer:)))
        self.songArtwork.addGestureRecognizer(singleTap)
        self.spectralViewOutlet.addGestureRecognizer(singleTap)
        print(singleTap)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: audio)
            self.player = sound
            sound.play()
            
        } catch {
            print("error loading file")
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
       
        
        spectralView = self.spectralViewOutlet as! SpectralView!
        self.view.addSubview(spectralView)
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
         audioInput.startRecording()
        

        
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }

    }
    
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        // Interpoloate the FFT data so there's one band per pixel.
        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
        
        tempi_dispatch_main { () -> () in
            self.spectralView.fft = fft
            self.spectralView.setNeedsDisplay()
        }
    }

    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func playPause(tapGestureRecognizer: UITapGestureRecognizer){
        if player != nil {
            if (player?.isPlaying)! {
                player?.stop()
                audioInput.stopRecording()
            } else {
                player?.play()
                audioInput.startRecording()
            }
        }
    }
    
    
}
