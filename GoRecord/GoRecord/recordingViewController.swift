//
//  recordingViewController.swift
//  GoRecord
//
//  Created by Max Nelson on 3/2/17.
//  Copyright © 2017 Max Nelson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation




class recordingViewController: UIViewController, AVAudioRecorderDelegate {
    
    //Variables
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    var audioInput: TempiAudioInput!
    var spectralView: SpectralView!
    
    var soundPlayer: AVAudioPlayer!
    
    let fileName = "newRecording.m4a"
    
    
    
    @IBOutlet weak var recordButtonOutlet: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    
    @IBOutlet weak var timerLabel: UILabel!
    var startTime = TimeInterval()
    var timer = Timer()
    var playTimer = String()
    
    
    
    //SAVE---
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        let path = getDocumentsDirectory().appendingPathComponent(self.fileName).path
        let url = URL(fileURLWithPath: path)
    
//        let file: FileHandle? = FileHandle(forReadingAtPath: path)
//        
//        if file == nil {
//            print("File open failed")
//        } else {
//            print("sending Audio")
////            let databuffer = file!.readDataToEndOfFile()
//            let parameters = ["songFile":"\(String(describing: file))"]
        
        
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "saveRecording") as! saveRecordingViewController
            vc.audioFile = url
            vc.audioFileName = self.fileName
            vc.audioFileLength = self.playTimer
            self.present(vc, animated: false, completion: nil)
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        
        print("yo")
        let path = getDocumentsDirectory().appendingPathComponent(self.fileName).path
        let url = URL(fileURLWithPath: path)
        print(url)
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            soundPlayer = sound
            sound.play()
            let aSelector:Selector = #selector(recordingViewController.playBackTime)
            self.startTime = NSDate.timeIntervalSinceReferenceDate
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        } catch {
            print("could not load file")
        }
    }
    
    
    func playBackTime(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime
        let minutes = Int(elapsedTime/60)
        elapsedTime -= (TimeInterval(minutes)*60)
        let seconds = Int(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        let fraction = Int(elapsedTime*100)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        self.timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        if self.timerLabel.text == self.playTimer{
            self.timer.invalidate()
            self.timer = Timer()
        }
    }
    
    
    
    
    
    
    func updateTime(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime
        let minutes = Int(elapsedTime/60)
        elapsedTime -= (TimeInterval(minutes)*60)
        let seconds = Int(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        let fraction = Int(elapsedTime*100)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        self.timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        
    }
    
    
    
    @IBAction func recordButton(_ sender: UIButton) {
        self.visualGraph.isHidden = false
        if audioRecorder == nil {
            if self.playButtonOutlet.isHidden == false {
                self.playButtonOutlet.isHidden = true
            }
            print("recording began")
            startRecording()
            let aSelector:Selector = #selector(recordingViewController.updateTime)
            self.playTimer = String()
            self.startTime = NSDate.timeIntervalSinceReferenceDate
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        } else {
            print("stopped audio")
            self.timer.invalidate()
            self.timer = Timer()
            self.playTimer = self.timerLabel.text!
            finishRecording(success: true)
            self.playButtonOutlet.isHidden = false
        }
    }
    
    
    @IBOutlet weak var visualGraph: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.playButtonOutlet.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.playButtonOutlet.isHidden = true
        
        
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){
                [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("session ready");
                    } else {
                        self.recordButtonOutlet.titleLabel?.text = "Please allow Rec. permissions"
                        print("failed to record 1")
                    }
                }
            }
        } catch {
            print("failed to record 2")
        }
        
        spectralView = self.visualGraph as! SpectralView!
        spectralView.backgroundColor = UIColor.black
        self.view.addSubview(spectralView)
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    
    
    func startRecording(){
        
       
        
       let audioFileName = getDocumentsDirectory().appendingPathComponent(self.fileName)
//        self.audioFile = audioFileName
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
       
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
         
            audioRecorder.record()
            
            audioInput.startRecording()
            
            print(audioRecorder.isRecording, "$$$$$$$")
            print(audioRecorder.peakPower(forChannel: 0))
            recordButtonOutlet.setTitle("Tap to Stop", for: .normal)
            
            
        
            
            print("Recording in progress")
        } catch {
            print("Start-Recording() failed")
            finishRecording(success:false)
        }
    }
    

    
    
    
    
    func finishRecording(success: Bool){
        print(success, "finish-Recording()")
        audioRecorder.stop()
        audioInput.stopRecording()
        audioRecorder = nil
        self.visualGraph.isHidden = true
        
        if success == true {
            recordButtonOutlet.setTitle("Tap to Re-Record", for: .normal)
        } else if success == false {
            recordButtonOutlet.setTitle("Tap to Record", for: .normal)
            print("recording failed /finish-Recording-Function")
        }
    }
    
    

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("fucked up")
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error \(String(describing: error))")
    }
    
    
    
    func getDocumentsDirectory()->URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }



}

