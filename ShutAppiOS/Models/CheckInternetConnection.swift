//
//  CheckInternetConnection.swift
//  ShutAppiOS
//
//  Created by Alexander Jansson on 2020-12-28.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import Network


final class CheckInternetConnection{
    
    static let shared = CheckInternetConnection()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init(){
        self.monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        
            self?.getConnectionType(path)
            
        }
    }
    
    public func  stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType (_ path:NWPath ){
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
        }
        else {
            connectionType = .unknown
        }
    }
}
