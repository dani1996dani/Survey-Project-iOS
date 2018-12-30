//
//  RoundedButton.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 16/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    var isOn = false
    let green = UIColor.init(red:78/255, green: 162/255, blue: 78/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton(){
        layer.borderWidth = 2.0
        layer.cornerRadius = frame.size.height / 2
        
        layer.borderColor = green.cgColor
        setTitleColor(green, for: .normal)
        addTarget(self, action: #selector(RoundedButton.buttonPressed), for: .touchUpInside)
        
    }
    
    @objc func buttonPressed(){
        activateButton(bool : !isOn)
    }
    
    func activateButton(bool : Bool){
        isOn = bool
        let color = isOn ? green : UIColor.clear
        backgroundColor = color
        setTitleColor(isOn ? UIColor.white : green, for: .normal)
        setTitle(isOn ? "Voted!" : "Vote", for: .normal)
    }
}
