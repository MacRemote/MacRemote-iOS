//
//  MRServiceTableViewController.swift
//  MacRemote iOS
//
//  Created by Tom Hu on 6/12/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

import UIKit
import MRFoundation
import CocoaAsyncSocket

class MRServiceTableViewController: UITableViewController, MRRemoteControlClientDelegate {
    
    private var services: Array<NSNetService>!

    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.services = []
        
        MRRemoteControlClient.sharedClient.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Start searching services
        MRRemoteControlClient.sharedClient.startSearch()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop searching services
        MRRemoteControlClient.sharedClient.stopSearch()
    }
    
    // MARK: - MRRemoteControlClientDelegate
    
    func remoteControlClientDidChangeServices(services: Array<NSNetService>) {
        print("Reload data")
        self.services = services
        
        self.tableView.reloadData()
    }
    
    func remoteControlClientWillConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket) {
        print("Client will connect to service")
    }
    
    func remoteControlClientDidConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket) {
        print("Client connected to service (\(service.name)).")
    }
    
    func remoteControlClientDidDisconnect() {
        print("Client disconnect with server!")
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func remoteControlClientDidSendData(data: NSData, toService service: NSNetService, onSocket socket: GCDAsyncSocket) {
        print("Sent data: \(data)")
        print("Length: \(data.length)")
    }
    
    func remoteControlClientDidReceiveData(data: NSData, fromService service: NSNetService, onSocket socket: GCDAsyncSocket) {
        print("Received data: \(data)")
        print("Length: \(data.length)")
    }

    // MARK: - Table View Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count != 0 ? self.services.count : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId: String = "serviceCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as! MRServiceTableViewCell

        if self.services.count == 0 {
            cell.serviceNameLabel.text = "(No service)"
            cell.userInteractionEnabled = false
            
            return cell
        }
        
        let service: NSNetService = self.services[indexPath.row]
        
        cell.serviceNameLabel.text = service.name
        cell.userInteractionEnabled = true

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
        let service: NSNetService = self.services[indexPath!.row]
        
        if let vc = segue.destinationViewController as? MRControlViewController {
            vc.service = service
        }
    }

}
