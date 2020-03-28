//
//  TorClient.swift
//  StandUp-iOS
//
//  Created by Peter on 12/01/19.
//  Copyright © 2019 BlockchainCommons. All rights reserved.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import Tor
import UIKit

protocol OnionManagerDelegate: class {

    func torConnProgress(_ progress: Int)

    func torConnFinished()

    func torConnDifficulties()
}

class TorClient {
    
    enum TorState {
        case none
        case started
        case connected
        case stopped
    }
    
    static let sharedInstance = TorClient()
    public var state = TorState.none
    private var config: TorConfiguration = TorConfiguration()
    private var thread: TorThread?
    private var controller: TorController?
    private var authDirPath = ""
    private var torDirPath = ""
    var progress = Int()
    
    // The tor url session configuration.
    // Start with default config as fallback.
    private lazy var sessionConfiguration: URLSessionConfiguration = .default

    // The tor client url session including the tor configuration.
    lazy var session = URLSession(configuration: sessionConfiguration)

    // Start the tor client.
    func start(delegate: OnionManagerDelegate?, completion: @escaping () -> Void) {
        print("start")
        
        weak var weakDelegate = delegate
        state = .started
        
        //add V3 auth keys to ClientOnionAuthDir if any exist
        let torDir = self.createTorDirectory()
        self.authDirPath = self.createAuthDirectory()
        
        self.clearAuthKeys {
            
            self.addAuthKeysToAuthDirectory {
                
                // Make sure we don't have a thread already.
                if self.thread?.isCancelled ?? true {
                    
//                    DispatchQueue.main.async {
//                        
//                        NotificationCenter.default.post(name: .didStartBootstrappingTor, object: nil, userInfo: nil)
//                        
//                    }
                    
                    self.thread = nil
                                        
                    self.config.options = [
                        
                        "DNSPort": "12346",
                        "AutomapHostsOnResolve": "1",
                        "SocksPort": "29050 OnionTrafficOnly",
                        "AvoidDiskWrites": "1",
                        "ClientOnionAuthDir": "\(self.authDirPath)",
                        "LearnCircuitBuildTimeout": "1",
                        "NumEntryGuards": "8",
                        "SafeSocks": "1",
                        "LongLivedPorts": "80,443",
                        "NumCPUs": "2",
                        "DisableDebuggerAttachment": "1",
                        "SafeLogging": "1",
                        "ExcludeExitNodes": "1",
                        "StrictNodes": "1"
                        
                    ]
                    
                    self.config.cookieAuthentication = true
                    self.config.dataDirectory = URL(fileURLWithPath: torDir)
                    self.config.controlSocket = self.config.dataDirectory?.appendingPathComponent("cp")
                    self.config.arguments = ["--ignore-missing-torrc"]
                    
                } else {
                    
                    print("thread is not nil")
                    
                }
                
                // Initiate the controller.
                if self.controller == nil {
                    self.controller = TorController(socketURL: self.config.controlSocket!)
                }
                
                self.thread = TorThread(configuration: self.config)
                
                // Start a tor thread.
                self.thread?.start()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Connect Tor controller.
                    
                    do {
                        
                        if !(self.controller?.isConnected ?? false) {
                            do {
                                try self.controller?.connect()
                            } catch {
                                print("error=\(error)")
                            }
                        }
                        
                        let cookie = try Data(
                            
                            contentsOf: self.config.dataDirectory!.appendingPathComponent("control_auth_cookie"),
                            options: NSData.ReadingOptions(rawValue: 0)
                            
                        )
                        
                        print("got cookie")
                        
                        self.controller?.authenticate(with: cookie) { success, error in
                                                        
                            if let error = error {
                                
                                print("error = \(error.localizedDescription)")
                                return
                                
                            }
                            
                            let _ = self.controller?.addObserver(forCircuitEstablished: { established in
                                
                                if established {
                                    
                                    self.state = .connected
                                    
                                    self.sessionConfiguration.connectionProxyDictionary = [kCFProxyTypeKey: kCFProxyTypeSOCKS, kCFStreamPropertySOCKSProxyHost: "localhost", kCFStreamPropertySOCKSProxyPort: 29050]
                                    self.session = URLSession(configuration:self.sessionConfiguration)
                                    self.session.configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
                                    weakDelegate?.torConnFinished()
                                    
                                    DispatchQueue.main.async {
                                        
                                        NotificationCenter.default.post(name: .didEstablishTorConnection, object: self)
                                        
                                    }
                                    
                                    completion()
                                    
                                }
                                
                            })
                                        
                        }
                        
                    } catch {
                        
                        print("failed connecting tor")
                        self.state = .none
                        completion()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func closeCircuits(_ circuits: [TorCircuit], _ callback: @escaping ((_ success: Bool) -> Void)) {
        controller?.close(circuits, completion: callback)
    }
    
    func getCircuits(_ callback: @escaping ((_ circuits: [TorCircuit]) -> Void)) {
        controller?.getCircuits(callback)
    }
    
    func resign() {
        print("resign")
        
        self.controller?.disconnect()
        self.controller = nil
        
        // More cleanup
        self.thread?.cancel()
        self.thread = nil
        
        self.clearAuthKeys {}
        state = .stopped
        
    }
    
//    private func connectController(delegate: OnionManagerDelegate?, completion: @escaping () -> Void) {
//        print("connectController")
//        do {
//            if !(self.controller?.isConnected ?? false) {
//                try self.controller?.connect()
//                print("tor controller connected")
//            }
//
//            try self.authenticateController(delegate: delegate) {
//                print("authenticateController")
//                //TORInstallEventLogging()
//                //TORInstallTorLogging()
//                completion()
//            }
//
//        } catch {
//            print("error connecting tor controller")
//            self.state = .none
//            completion()
//        }
//
//    }
//
//    private func authenticateController(delegate: OnionManagerDelegate?, completion: @escaping () -> Void) throws -> Void {
//        print("authenticateController")
//
//        let cookie = try Data(
//
//            contentsOf: config.dataDirectory!.appendingPathComponent("control_auth_cookie"),
//            options: NSData.ReadingOptions(rawValue: 0)
//
//        )
//
//        print("got cookie")
//
//        self.controller?.authenticate(with: cookie) { success, error in
//
//            if let error = error {
//
//                print("error = \(error.localizedDescription)")
//                return
//
//            }
//
//            var observer: Any? = nil
//            observer = self.controller?.addObserver(forCircuitEstablished: { established in
//
//                if established {
//
//                    self.state = .connected
//
//                    print("observer added")
//                    self.controller?.getSessionConfiguration() { sessionConfig in
//
//                        self.sessionConfiguration.connectionProxyDictionary = [kCFProxyTypeKey: kCFProxyTypeSOCKS, kCFStreamPropertySOCKSProxyHost: "localhost", kCFStreamPropertySOCKSProxyPort: 29050]
//                        self.session = URLSession(configuration: self.sessionConfiguration)
//                        self.session.configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
//                        self.controller?.removeObserver(observer)
//                        delegate?.torConnFinished()
//
//                    }
//
//                    completion()
//
//                }
//
//            })
//
//            var progressObs: Any?
//            progressObs = self.controller?.addObserver(forStatusEvents: {
//                (type: String, severity: String, action: String, arguments: [String : String]?) -> Bool in
//
//                if type == "STATUS_CLIENT" && action == "BOOTSTRAP" {
//                    let progress = Int(arguments!["PROGRESS"]!)!
//                    #if DEBUG
//                    print("progress=\(progress)")
//                    #endif
//
//                    delegate?.torConnProgress(progress)
//
//                    if progress >= 100 {
//
//                        DispatchQueue.main.async {
//
//                            NotificationCenter.default.post(name: .didEstablishTorConnection, object: self)
//
//                        }
//
//                        self.controller?.removeObserver(progressObs)
//                    }
//
//                    return true
//                }
//
//                return false
//            })
//
//        }
//
//    }
    
    private func createTorDirectory() -> String {
        print("createTorDirectory")
        
        torDirPath = self.getTorPath()
        
        do {
            
            try FileManager.default.createDirectory(atPath: torDirPath, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.posixPermissions: 0o700
                ])
            
        } catch {
            
            print("Directory previously created.")
            
        }
        
        return torDirPath
        
    }
    
    private func getTorPath() -> String {
        print("getTorPath")
        
        var torDirectory = ""
        
        #if targetEnvironment(simulator)
        print("is simulator")
        
        let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first ?? ""
        torDirectory = "\(path.split(separator: Character("/"))[0..<2].joined(separator: "/"))/.tor_tmp"
        
        #else
        print("is device")
        
        torDirectory = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? "")/tor"
        
        #endif
        
        return torDirectory
        
    }
    
    private func createAuthDirectory() -> String {
        print("createAuthDirectory")
        
        // Create tor v3 auth directory if it does not yet exist
        let authPath = URL(fileURLWithPath: self.torDirPath, isDirectory: true).appendingPathComponent("onion_auth", isDirectory: true).path
        
        do {
            
            try FileManager.default.createDirectory(atPath: authPath, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.posixPermissions: 0o700
                ])
            
        } catch {
            
            print("Auth directory previously created.")
            
        }
        
        return authPath
        
    }
    
    private func addAuthKeysToAuthDirectory(completion: @escaping () -> Void) {
        print("addAuthKeysToAuthDirectory")
        
        let authPath = self.authDirPath
        let cd = CoreDataService()
        let enc = Encryption()
        cd.retrieveEntity(entityName: .nodes) { (entity, errorDescription) in
            
            if entity != nil {
                
                if entity!.count > 0 {
                    
                    let nodesCount = entity!.count
                    
                    for (i, n) in entity!.enumerated() {
                                                                        
                        cd.retrieveEntity(entityName: .auth) { (authKeys, errorDescription) in
                            
                            if errorDescription == nil {
                                
                                if authKeys != nil {
                                    
                                    if authKeys!.count > 0 {
                                        
                                        if let encryptedPrivkey = authKeys![0]["privkey"] as? Data {
                                            
                                            enc.decryptData(dataToDecrypt: encryptedPrivkey) { (decryptedPrivkey) in
                                                
                                                if decryptedPrivkey != nil {
                                                    
                                                    let authorizedKey = String(bytes: decryptedPrivkey!, encoding: .utf8)!
                                                    let encryptedOnionAddress = n["onionAddress"] as! Data
                                                    
                                                    enc.decryptData(dataToDecrypt: encryptedOnionAddress) { (decryptedOnion) in
                                                        
                                                        if decryptedOnion != nil {
                                                            
                                                            let onionAddress = String(bytes: decryptedOnion!, encoding: .utf8)!
                                                            let onionAddressArray = onionAddress.components(separatedBy: ".onion:")
                                                            let authString = onionAddressArray[0] + ":descriptor:x25519:" + authorizedKey
                                                            let file = URL(fileURLWithPath: authPath, isDirectory: true).appendingPathComponent("\(randomString(length: 10)).auth_private")
                                                            
                                                            do {
                                                                
                                                                try authString.write(to: file, atomically: true, encoding: .utf8)
                                                                print("successfully wrote authkey to file")
                                                                
                                                                do {
                                                                    
                                                                    try (file as NSURL).setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)
                                                                    print("success setting file protection")
                                                                    
                                                                } catch {
                                                                    
                                                                   print("error setting file protection")
                                                                    
                                                                }
                                                                
                                                                if i + 1 == nodesCount {
                                                                    
                                                                    completion()
                                                                    
                                                                }
                                                                
                                                            } catch {
                                                                
                                                                print("failed writing auth key")
                                                                completion()
                                                            }
                                                            
                                                        } else {
                                                            
                                                            print("failed decrypting onion address")
                                                            completion()
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                } else {
                                                    
                                                    print("failed decrypting private key")
                                                    completion()
                                                    
                                                }
                                                
                                            }
                                            
                                        } else {
                                            
                                            print("failed writing auth key")
                                            completion()
                                            
                                        }
                                        
                                    } else {
                                        
                                        print("no authkeys")
                                        completion()
                                    }
                                    
                                } else {
                                    
                                    print("error getting auth keys")
                                    completion()
                                    
                                }
                                
                            } else {
                                
                                print("error getting authkeys")
                                completion()
                                
                            }
                            
                        }
                        
                    }
                    
                }  else {
                    
                    print("no nodes")
                    completion()
                    
                }
                
            } else {
                
                print("no nodes")
                completion()
                
            }
            
        }
        
    }
    
    private func clearAuthKeys(completion: @escaping () -> Void) {
        
        //removes all authkeys
        let fileManager = FileManager.default
        let authPath = self.authDirPath
        
        do {
            
            let filePaths = try fileManager.contentsOfDirectory(atPath: authPath)
            
            for filePath in filePaths {
                
                let url = URL(fileURLWithPath: authPath + "/" + filePath)
                try fileManager.removeItem(at: url)
                print("deleted key")
                
            }
            
            completion()
            
        } catch {
            
            print("error deleting existing keys")
            completion()
            
        }
        
    }
    
}
