//
//  GetSmartFee.swift
//  StandUp-iOS
//
//  Created by Peter on 12/01/19.
//  Copyright © 2019 BlockchainCommons. All rights reserved.
//

import Foundation
import UIKit

class GetSmartFee {
    
//    var errorBool = Bool()
//    var errorDescription = ""
//    
//    var dictToReturn = NSDictionary()
//    var rawSigned = ""
//    var txSize = Int()
//    var vc:UIViewController!
//    var blockTarget = UserDefaults.standard.object(forKey: "feeTarget") as! Int
//    var optimalFee = Double()
//    var minimumFee = Double()
//    
//    var isUnsigned = false
//    
//    func getSmartFee(completion: @escaping () -> Void) {
//        
//        let reducer = Reducer()
//        
//        func get(method: BTC_CLI_COMMAND, param: String) {
//            
//            func getResult() {
//                
//                if !reducer.errorBool {
//                    
//                    switch method {
//                        
//                    case .estimatesmartfee:
//                        
//                        let dict = reducer.dictToReturn
//                        optimalFee = getOptimalFee(dict: dict, vsize: txSize)
//                        completion()
//                        
//                    case .decoderawtransaction:
//                        
//                        let dict = reducer.dictToReturn
//                        txSize = dict["vsize"] as! Int
//                        
//                        get(method: .estimatesmartfee,
//                            param: "\(blockTarget)")
//                        
//                    default:
//                        
//                        break
//                        
//                    }
//                    
//                } else {
//                    
//                    errorBool = true
//                    errorDescription = reducer.errorDescription
//                    
//                }
//                
//            }
//            
//            reducer.makeCommand(walletName: <#String#>, command: method,
//                                param: param,
//                                completion: getResult)
//            
//        }
//        
//        get(method: .decoderawtransaction,
//            param: "\"\(self.rawSigned)\"")
//        
//    }
//    
//    func getOptimalFee(dict: NSDictionary, vsize: Int) -> Double {
//        
//        var size = vsize
//        
//        if isUnsigned {
//            
//            size += 100
//            
//        }
//        
//        let txSize = Double(size)
//        var btcPerKbyte = Double()
//        
//        if let btcPerKbyteCheck = dict["feerate"] as? Double {
//            
//            btcPerKbyte = btcPerKbyteCheck
//            
//        } else {
//            
//            // Node is likely in regtest mode so fee estimation is wierd
//            btcPerKbyte = 0.00000100
//            
//        }
//        
//        let btcPerByte = btcPerKbyte / 1000
//        let optimalFee = btcPerByte * txSize
//        
//        return optimalFee
//        
//    }
    
}
