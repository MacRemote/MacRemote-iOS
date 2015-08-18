//
//  ViewController.swift
//  MacRemote iOS
//
//  Created by Tom Hu on 6/12/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

import UIKit
import MRFoundation

class MRControlViewController: UIViewController {
    
    var service: NSNetService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect to service
        MRRemoteControlClient.sharedClient.connectToService(self.service)
    }
    
    deinit {
        println("Deinitializing...")
        println("Exit")
        MRRemoteControlClient.sharedClient.disconnect()
    }

    // MARK: - Actions
    // MARK: Sound
    @IBAction func didClickSoundUpButton(sender: UIButton) {
        var event: MREvent = MREvent(eventType: MREventType.SoundUp, message: "Sound Up")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    @IBAction func didClickSoundDownButton(sender: UIButton) {
        var event: MREvent = MREvent(eventType: MREventType.SoundDown, message: "Sound Down")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    @IBAction func didClickSoundMuteButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.SoundMute, message: "Sound Mute")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    // MARK: Brightness
    @IBAction func didClickBrightnessUpButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.BrightnessUp, message: "Brightness Lighten")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    @IBAction func didClickBrightnessDownButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.BrightnessDown, message: "Brightness Darken")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    // MARK: Illumination
    @IBAction func didClickIlluminationUpButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.IlluminationUp, message: "Illumination Up")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    @IBAction func didClickIlluminationDownButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.IlluminationDown, message: "Illumination Down")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }
    
    @IBAction func didClickIlluminationToggleButton(sender: UIButton) {
        var event = MREvent(eventType: MREventType.IlluminationToggle, message: "Illumination Toggle")
        MRRemoteControlClient.sharedClient.send(event.data!)
    }

}

