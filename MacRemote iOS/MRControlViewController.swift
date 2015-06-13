//
//  ViewController.swift
//  MacRemote iOS
//
//  Created by Tom Hu on 6/12/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

import UIKit

class MRControlViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didClickSendButton(sender: UIButton) {
        if let data = self.inputTextField.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            MRRemoteControlClient.sharedClient.send(data)
        }
    }

}

