//
//  MRServiceTableViewController.swift
//  MacRemote iOS
//
//  Created by Tom Hu on 6/12/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class MRServiceTableViewController: UITableViewController, MRRemoteControlClientDelegate {
    
    private var remoteControlClient: MRRemoteControlClient!
    private var services: Array<NSNetService>!

    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        self.services = []
        
        self.remoteControlClient = MRRemoteControlClient()
        self.remoteControlClient.delegate = self
        self.remoteControlClient.startSearch()
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
        return self.services.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId: String = "serviceCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as MRServiceTableViewCell

        var service: NSNetService = self.services[indexPath.row]
        
        cell.serviceNameLabel.text = service.name

        return cell
    }

}
