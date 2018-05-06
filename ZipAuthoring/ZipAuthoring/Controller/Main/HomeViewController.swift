//
//  HomeViewController.swift
//  ZipAuthoring
//
//  Created by xr on 5/2/18.
//  Copyright © 2018 Dusan. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {

    @IBOutlet weak var m_timeLabel: UILabel!
    @IBOutlet weak var navBarView: UIView!
//    @IBOutlet weak var m_tableview: UITableView!
    

    var selected_index: IndexPath?
    
    var recorder: AVAudioRecorder!
//    var player: AVAudioPlayer!
    
    var m_datasource = [RecordModel]()

    
    var soundFileURL: URL!
    var meterTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()

        askForNotifications()
        checkHeadphones()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
    }
    
    @IBAction func onTrash(_ sender: Any) {
    }
    
    @IBAction func onEdit(_ sender: Any) {
        
    }
    
    @IBAction func onExport(_ sender: Any) {
        let activityContrller = UIActivityViewController(activityItems: ["Test"], applicationActivities: nil)
        if activityContrller.responds(to: #selector(getter: popoverPresentationController)) {
            activityContrller.popoverPresentationController?.sourceView = self.view
        }
        self.present(activityContrller, animated: true, completion: nil)
    }
    
    @IBAction func onTranscribe(_ sender: Any) {
    }
    
    @IBAction func onRecord(_ sender: UIButton) {
        if recorder == nil {
            print("recording. recorder nil")
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("stop")
            self.stop()
            
        } else {
            print("recording")
            recordWithPermission(false)
        }
    }
    
    func stop() {
        print("\(#function)")
        recorder?.stop()
        
        meterTimer.invalidate()
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setActive(false)
        } catch {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onSearchItem(_ sender: Any) {
   
    }
    
    @IBAction func onSettingItem(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        
        if let recorder = self.recorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                self.m_timeLabel.text = s
                recorder.updateMeters()
            }
        }
    }
    
    
    func setupView() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func askForNotifications() {
        print("\(#function)")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HomeViewController.background(_:)),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HomeViewController.foreground(_:)),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HomeViewController.routeChange(_:)),
                                               name: NSNotification.Name.AVAudioSessionRouteChange,
                                               object: nil)
    }
    
    @objc func background(_ notification: Notification) {
        print("\(#function)")
    }
    
    @objc func foreground(_ notification: Notification) {
        print("\(#function)")
    }
    
    
    @objc func routeChange(_ notification: Notification) {
        print("\(#function)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            print("routeChange \(userInfo)")
            
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
        
        // this cast fails. that's why I do that goofy thing above.
        //        if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason {
        //        }
        
        /*
         AVAudioSessionRouteChangeReasonUnknown = 0,
         AVAudioSessionRouteChangeReasonNewDeviceAvailable = 1,
         AVAudioSessionRouteChangeReasonOldDeviceUnavailable = 2,
         AVAudioSessionRouteChangeReasonCategoryChange = 3,
         AVAudioSessionRouteChangeReasonOverride = 4,
         AVAudioSessionRouteChangeReasonWakeFromSleep = 6,
         AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory = 7,
         AVAudioSessionRouteChangeReasonRouteConfigurationChange NS_ENUM_AVAILABLE_IOS(7_0) = 8
         
         routeChange Optional([AVAudioSessionRouteChangeReasonKey: 1, AVAudioSessionRouteChangePreviousRouteKey: <AVAudioSessionRouteDescription: 0x17557350,
         inputs = (
         "<AVAudioSessionPortDescription: 0x17557760, type = MicrophoneBuiltIn; name = iPhone Microphone; UID = Built-In Microphone; selectedDataSource = Bottom>"
         );
         outputs = (
         "<AVAudioSessionPortDescription: 0x17557f20, type = Speaker; name = Speaker; UID = Built-In Speaker; selectedDataSource = (null)>"
         )>])
         routeChange Optional([AVAudioSessionRouteChangeReasonKey: 2, AVAudioSessionRouteChangePreviousRouteKey: <AVAudioSessionRouteDescription: 0x175562f0,
         inputs = (
         "<AVAudioSessionPortDescription: 0x1750c560, type = MicrophoneBuiltIn; name = iPhone Microphone; UID = Built-In Microphone; selectedDataSource = Bottom>"
         );
         outputs = (
         "<AVAudioSessionPortDescription: 0x17557de0, type = Headphones; name = Headphones; UID = Wired Headphones; selectedDataSource = (null)>"
         )>])
         */
    }
    
    func checkHeadphones() {
        print("\(#function)")
        
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if !currentRoute.outputs.isEmpty {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    func recordWithPermission(_ setup: Bool) {
        print("\(#function)")
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: #selector(self.updateAudioMeter(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission() == .denied {
            print("permission denied")
        }
    }
    
    func setupRecorder() {
        print("\(#function)")
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func setSessionPlayAndRecord() {
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.m_datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCellTableViewCell", for: indexPath) as! RecordCellTableViewCell
        let item = self.m_datasource[indexPath.row]
        cell.setupCell(item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.m_datasource[indexPath.row]
        item.is_play = !item.is_play
    }
    
}


// MARK: AVAudioRecorderDelegate
extension HomeViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("\(#function)")

        // iOS8 and later
        let alert = UIAlertController(title: "Recorder",
                                      message: "Finished Recording",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default) {[unowned self] _ in
            self.recorder = nil
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .default) {[unowned self] _ in
            self.recorder.deleteRecording()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("\(#function)")
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
}
