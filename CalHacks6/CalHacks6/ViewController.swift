//
//  ViewController.swift
//  CalHacks6
//
//  Created by Arman Vaziri on 10/26/19.
//  Copyright © 2019 ArmanVaziri. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recTableView: UITableView!
    
    var recording: Bool = false
    var playing: Bool = false
    var time: Int = 0
    var timer: Timer = Timer()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Audio Session setup
        recordingSession = AVAudioSession.sharedInstance()
        
//        if let number : Int = UserDefaults.standard.object(forKey: "myNumber") as? Int
//        {
//            numberOfRecords = number
//        }
//
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Microphone access granted")
            }
        }
    }
    
    @objc func startTime() {
        time += 1
        timeLabel.text = String(time)
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
        
        recTableView.backgroundColor = UIColor.clear
        
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        // Check if we have an active recorder
        if audioRecorder == nil {
             
            numberOfRecords += 1
            let fileName = getDir().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : 48000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue]
            
            // start audio recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                recording = true
                sender.pulse()
                sender.setTitle("Stop", for: UIControl.State.normal)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.startTime), userInfo: nil, repeats: true)
                
            } catch {
                displayAlert(title: "Error!", message: "Sorry, something is wrong with your microphone ")
            }
            
        // Stopping audio recording
        } else {
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            recTableView.reloadData()
            
            recording = false
            sender.pulse()
            sender.setTitle("Rec.", for: UIControl.State.normal)
            timer.invalidate()
        }
    }
    
    var selectedRecording: Int!
    
    // Send selected file to Flask Server
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if selectedRecording != nil {
            let audioFile = getDir().appendingPathComponent("\(selectedRecording +  1).m4a")
        }
        
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        sender.pulse()
    }
    
    // Get path to directory where the audio recording(s) will be stored
    func getDir() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    // Display alerts here for user knowledge
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title:  title, message: message, preferredStyle: .alert)
        alert.addAction(_ : .init(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
         
    }
    
    // Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath) as? TableViewCell {
            cell.cellLabel.text = "recording " + String(indexPath.row + 1)
            cell.backgroundColor = UIColor(white: 1, alpha: 0.25)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !self.playing {

            let path = getDir().appendingPathComponent("\(indexPath.row + 1).m4a")
        
            do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
            self.playing = true
                selectedRecording = indexPath.row
                print("selected recording : " + String(selectedRecording))
            } catch  {
            displayAlert(title: "Sorry", message: "The selection caused an error")
            }
        } else {
            audioPlayer.pause()
            self.playing = false
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
}

