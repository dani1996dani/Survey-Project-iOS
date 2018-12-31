//
//  NumberFormatter.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 12/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class NumberFormatter{
    
    ///Formats a number to a String representation. For example, the number 195,345 will be converted to: **195.3K**
    static func format(number: Int)-> String{
        if number < 1000{
            return String(number)
        }
        
        let thousands = number / 1000;
        let hundreds = NthDigit(number: number, magnitude: 3)
   
        if(number < 1000000){
            return "\(thousands).\(hundreds)K"
        }
        
        let millions = number / 1000000;
        let hundredThousandsDigit = NthDigit(number: number, magnitude: 6)
        return "\(millions).\(hundredThousandsDigit)M"
        
    }
    
    private static func NthDigit(number : Int,magnitude : Int) -> Int{
        if magnitude > String(number).count{
            return 0
        }
        if number == 0{
            return 0
        }
        
        if number < 10{
            return number
        }
        
        //for magnitude 3, the formula is : number % (10^3) / (10^2)
        return number % Int(pow(Double(10), Double(magnitude))) / Int(pow(Double(10), Double(magnitude - 1)))
    }
}
