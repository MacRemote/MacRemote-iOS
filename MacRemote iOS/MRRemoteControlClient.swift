//
//  MRRemoteControlClient.swift
//  MacRemote iOS
//
//  Created by Tom Hu on 6/13/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

enum PacketTag: Int {
    case Header = 1
    case Body = 2
}

// MARK: - Client Delegate Protocol
// WARNING: Using 'optional' causes problems
// FIXME: Using 'optional' keyword
protocol MRRemoteControlClientDelegate {
    func remoteControlClientDidChangeServices(services: Array<NSNetService>)
    
    func remoteControlClientWillConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket)
    func remoteControlClientDidConnectToService(service: NSNetService, onSocket socket: GCDAsyncSocket)
    
    func remoteControlClientDidSendData(data: NSData, toService service: NSNetService, onSocket socket: GCDAsyncSocket)
    
    func remoteControlClientDidReceiveData(data: NSData, fromService service: NSNetService, onSocket socket: GCDAsyncSocket)
}

// MARK: - Client
class MRRemoteControlClient: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate {
    
    var delegate: MRRemoteControlClientDelegate!
    private var serviceBrowser: NSNetServiceBrowser!
    private(set) var connectedService: NSNetService?
    private(set) var services: Array<NSNetService>!
    private(set) var connectedSocket: GCDAsyncSocket?
    
    override init() {
        super.init()
        
        self.services = []
    }
    
    func startSearch() {
        println("Searching services...")
        if self.services != nil {
            self.services.removeAll(keepCapacity: true)
        }
        
        self.serviceBrowser = NSNetServiceBrowser()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.searchForServicesOfType("_macremote._tcp.", inDomain: "local.")
    }
    
    func stopSearch() {
        if self.serviceBrowser != nil {
            self.serviceBrowser.stop()
            self.serviceBrowser.delegate = nil
            self.serviceBrowser = nil
        }
    }
    
    func connectToService(service: NSNetService) {
        service.delegate = self
        service.resolveWithTimeout(10)
    }
    
    private func connectToServerWithService(service: NSNetService) -> Bool {
        var isConnected = false
        
        let addresses: Array = service.addresses!
        
        if !(self.connectedSocket?.isConnected != nil) {
            // Initialize Socket
            self.connectedSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            
            // Connect
            while !isConnected && Bool(addresses.count) {
                let address: NSData = addresses[0] as NSData
                var error: NSError?
                
                if (self.connectedSocket?.connectToAddress(address, error: &error) != nil) {
                    self.connectedService = service
                    isConnected = true
                } else if error != nil {
                    // Error handle
                    println("Unable to connect to address.\nError \(error?) with user info \(error?.userInfo)")
                }
            }
        } else {
            isConnected = self.connectedSocket!.isConnected
        }
        
        return isConnected
    }
    
    private func parseHeader(data: NSData) -> UInt {
        var out: UInt = 0
        data.getBytes(&out, length: sizeof(UInt))
        return out
    }
    
    func send(data: NSData) {
        println("Sending data to server!")
        
        var header = data.length
        let headerData = NSData(bytes: &header, length: sizeof(UInt))
        
        self.connectedSocket?.writeData(headerData, withTimeout: -1.0, tag: PacketTag.Header.rawValue)
        self.connectedSocket?.writeData(data, withTimeout: -1.0, tag: PacketTag.Body.rawValue)
        
        self.delegate.remoteControlClientDidSendData(data, toService: self.connectedService!, onSocket: self.connectedSocket!)
    }
    
    // MARK: - NSNetServiceBrowserDelegate
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("Will search service")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        println("Find a service: \(aNetService.name)")
        println("Port: \(aNetService.port)")
        println("Domain: \(aNetService.domain)")
        
        self.services.append(aNetService)
        if !moreComing {
            self.delegate.remoteControlClientDidChangeServices(self.services)
        }
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        println("Remove a service: \(aNetService.name)")
        
        self.services.removeObject(aNetService)
        if !moreComing {
            self.delegate.remoteControlClientDidChangeServices(self.services)
        }
    }
    
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("Stop search!")
        
        self.stopSearch()
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        println("Start search...")
        
        self.startSearch()
    }
    
    // MARK: - NSNetServiceDelegate
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        println("Did resolve address: \(sender.addresses)")
        
        if self.connectToServerWithService(sender) {
            println("Connecting to \(sender.name)")
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println("Did not resolve.\n Error: \(errorDict)")
    }
    
    // MARK: - GCDAsyncSocketDelegate
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        println("Connected to host: \(host)")
        println("Port: \(port)")
        
        self.delegate.remoteControlClientDidConnectToService(self.connectedService!, onSocket: self.connectedSocket!)
        
        sock.readDataToLength(UInt(sizeof(UInt)), withTimeout: -1.0, tag: PacketTag.Header.rawValue)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        println("Socket did disconnect \(sock), error: \(err.userInfo)")
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        println("Read data")
        
        if self.connectedSocket == sock {
            if data.length == sizeof(UInt) {
                // Header
                let bodyLength: UInt = self.parseHeader(data)
                
                sock.readDataToLength(bodyLength, withTimeout: -1.0, tag: PacketTag.Body.rawValue)
            } else {
                // Body
                self.delegate.remoteControlClientDidReceiveData(data, fromService: self.connectedService!, onSocket: self.connectedSocket!)
                
                sock.readDataToLength(UInt(sizeof(UInt)), withTimeout: -1.0, tag: PacketTag.Header.rawValue)
            }
        }
    }
    
    func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        println("Closed read stream.")
    }
    
}
