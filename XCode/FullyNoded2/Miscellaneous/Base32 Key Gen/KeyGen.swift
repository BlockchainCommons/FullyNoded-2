//
//  KeyGen.swift
//  StandUp-iOS
//
//  Created by Peter on 12/01/19.
//  Copyright © 2019 BlockchainCommons. All rights reserved.
//

import CryptoKit
import Foundation

class KeyGen {
    
    class func generate() -> (pubKey: String, privKey: String) {
                    
            let privKeyRaw = Curve25519.KeyAgreement.PrivateKey.init()
            let pubKeyRaw = privKeyRaw.publicKey
            
            let privKeyData = privKeyRaw.rawRepresentation
            let pubkeyData = pubKeyRaw.rawRepresentation
            
            let privkeyBase32 = privKeyData.base32EncodedString
            let pubkeyBase32 = pubkeyData.base32EncodedString
            
            let privKey = privkeyBase32.replacingOccurrences(of: "====", with: "")
            let pubKey = pubkeyBase32.replacingOccurrences(of: "====", with: "")
            return (pubKey, privKey)
        
    }
    
}


