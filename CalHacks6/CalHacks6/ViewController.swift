//
//  ViewController.swift
//  CalHacks6
//
//  Created by Arman Vaziri on 10/26/19.
//  Copyright © 2019 ArmanVaziri. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate  {

    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Setting up audio session
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Microphone access granted")
            }
        }
         
    }
    
    // All UI setup done in this function, called in viewDidLoad
    func setupUI() {
        
        recordButton.layer.cornerRadius = recordButton.frame.height/2
        recordButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        recordButton.layer.shadowOpacity = 0.5
        
        resetButton.layer.cornerRadius = resetButton.frame.height/2
        resetButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        resetButton.layer.shadowOpacity = 0.5
        
        playButton.layer.cornerRadius = playButton.frame.height/2
        playButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        playButton.layer.shadowOpacity = 0.5
        
    }
    
    // Gets path to URL
    func getDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
        
    }
    
    var recording: Bool = false
    
    var time: Int = 0
    
    var timer: Timer = Timer()
    
    @objc func startTime() {
        time += 1
        timeLabel.text = String(time)
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if !recording {
            recording = true
            sender.pulse()
            sender.setTitle("Stop", for: UIControl.State.normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.startTime), userInfo: nil, repeats: true)
        } else {
            recording = false
            sender.pulse()
            sender.setTitle("Rec.", for: UIControl.State.normal)
            timer.invalidate()
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if !recording {
            sender.pulse()
            time = 0
            timeLabel.text = String(time) 
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        sender.pulse()
    }
    
    

}

