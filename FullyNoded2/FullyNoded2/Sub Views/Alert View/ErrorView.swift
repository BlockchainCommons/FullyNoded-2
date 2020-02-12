//
//  ErrorView.swift
//  StandUp-iOS
//
//  Created by Peter on 12/01/19.
//  Copyright © 2019 BlockchainCommons. All rights reserved.
//

import Foundation
import UIKit

class ErrorView: UIView {
    
    let errorLabel = UILabel()
    let impact = UIImpactFeedbackGenerator()
    let upSwipe = UISwipeGestureRecognizer()
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    @objc func handleSwipes(_ sender: UIGestureRecognizer) {
        
        print("handleSwipes")
     
        UIView.animate(withDuration: 0.2, animations: {
            
            self.backgroundView.frame = CGRect(x: 0,
                                          y: -61,
                                          width: self.backgroundView.frame.width,
                                          height: 61)
            
            self.errorLabel.frame = CGRect(x: 16,
                                           y: -61,
                                           width: self.backgroundView.frame.width,
                                           height: 61)
            
        }) { _ in
            
            UIView.animate(withDuration: 0.2, animations: {
                
                
            }, completion: { _ in
                
                self.backgroundView.removeFromSuperview()
                
            })
            
        }
        
    }
    
    func showErrorView(vc: UIViewController, text: String, isError: Bool) {
        
        self.isUserInteractionEnabled = true
        upSwipe.direction = .up
        upSwipe.addTarget(self, action: #selector(handleSwipes(_:)))
        backgroundView.addGestureRecognizer(self.upSwipe)
        
        let width = vc.view.frame.width
        
        backgroundView.frame = CGRect(x: 0,
                                      y: -61,
                                      width: width,
                                      height: 61)
        
        
        backgroundView.alpha = 0
        
        
        
        if isError {
            
            errorLabel.textColor = .red
            
        } else {
            
            errorLabel.textColor = .green
            
        }
        
        errorLabel.frame = CGRect(x: 16,
                                  y: -61,
                                  width: width - 32,
                                  height: 61)
        
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.text = text.lowercased()
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .left
        backgroundView.contentView.addSubview(errorLabel)
        vc.view.addSubview(backgroundView)
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.image = UIImage(named: "Image-12")
        
        UIView.animate(withDuration: 0.3, animations: {
            
            if vc.navigationController != nil {
                
                guard let y = vc.navigationController?.navigationBar.frame.maxY else {
                    return
                }
                
                self.backgroundView.alpha = 1
                
                self.backgroundView.frame = CGRect(x: 0,
                                                   y: y,
                                                   width: width,
                                                   height: 61)
                
                self.errorLabel.frame = CGRect(x: 16,
                                               y: 0,
                                               width: width,
                                               height: 61)
                
            } else {
                
                self.backgroundView.alpha = 1
                
                self.backgroundView.frame = CGRect(x: 0,
                                                   y: 100,
                                                   width: width,
                                                   height: 61)
                
                self.errorLabel.frame = CGRect(x: 16,
                                               y: 0,
                                               width: width,
                                               height: 61)
            }
            
        }) { _ in
            
            DispatchQueue.main.async {
                
                //imageView.alpha = 0.2
//                imageView.frame = CGRect(x: self.errorLabel.frame.midX - 15,
//                                         y: self.errorLabel.frame.maxY - 18,
//                                         width: 20,
//                                         height: 20)
                
                //self.errorLabel.addSubview(imageView)
                
                self.impact.impactOccurred()
                
            }
            
            let deadlineTime = 8.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + deadlineTime, execute: {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.backgroundView.frame = CGRect(x: 0,
                                                       y: -61,
                                                       width: width,
                                                       height: 61)
                    
                    self.errorLabel.frame = CGRect(x: 16,
                                                   y: -61,
                                                   width: width,
                                                   height: 61)
                    
                }) { _ in
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        
                    }, completion: { _ in
                        
                        self.backgroundView.removeFromSuperview()
             
                    })
                    
                }
                
            })
            
        }
        
    }
    
}
