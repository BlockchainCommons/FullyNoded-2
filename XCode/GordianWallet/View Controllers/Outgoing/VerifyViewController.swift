//
//  VerifyViewController.swift
//  StandUp-Remote
//
//  Created by Peter on 03/01/20.
//  Copyright © 2020 Blockchain Commons, LLC. All rights reserved.
//

import UIKit

class VerifyViewController: UIViewController {

    var address = ""
    let connectingView = ConnectingView()
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectingView.addConnectingView(vc: self, description: "getting address info")
        getAddressInfo(address: address)
        
    }
    
    func getAddressInfo(address: String) {
        
        let param = "\"\(address)\""
        
        getActiveWalletNow { [unowned vc = self] (wallet, error) in
            
            if wallet != nil && !error {
                
                Reducer.makeCommand(walletName: wallet!.name!, command: .getaddressinfo, param: param) { (object, errorDesc) in
                    
                    if let dict = object as? NSDictionary {
                        
                        DispatchQueue.main.async {
                            
                            vc.connectingView.removeConnectingView()
                            vc.textView.text = "\(dict)"
                            
                        }
                        
                    } else {
                        
                        vc.connectingView.removeConnectingView()
                        displayAlert(viewController: vc, isError: true, message: errorDesc ?? "unknown error")
                        
                    }
                    
                }
                
            }
            
        }
        
    }

}
