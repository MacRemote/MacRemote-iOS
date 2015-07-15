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

        self.clearsSelectionOnViewWillAppear = false
        
        self.services = []
        
        MRRemoteControlClient.sharedClient.delegate = self
        MRRemoteControlClient.sharedClient.startSearch()
    }
    
    // MARK: - MRRemoteControlClientDelegate
    
    func remoteControlClientDidChangeServices(services: Array<NSNetService>) {
        self.services = services
        
        self.tableView.reloadData()
    }
    
    func remoteControlClientWillConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket) {
        println("Client will connect to service")
    }
    
    func remoteControlClientDidConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket) {
        println("Client connected to service (\(service.name)).")
    }
    
    func remoteControlClientDidSendData(data: NSData, toService service: NSNetService, onSocket socket: GCDAsyncSocket) {
        println("Sent data: \(data)")
        if let message = NSString(data: data, encoding: NSUTF8StringEncoding) {
            println("Message: \(message)")
        }
        println("Length: \(data.length)")
    }
    
    func remoteControlClientDidReceiveData(data: NSData, fromService service: NSNetService, onSocket socket: GCDAsyncSocket) {
        println("Received data: \(data)")
        println("Length: \(data.length)")
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as MRServiceTableViewCell

        if self.services.count == 0 {
            cell.serviceNameLabel.text = "(No service)"
            
            return cell
        }
        
        var service: NSNetService = self.services[indexPath.row]
        
        cell.serviceNameLabel.text = service.name

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var service: NSNetService = self.services[indexPath.row]
        
        MRRemoteControlClient.sharedClient.connectToService(service)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
