//
//  TimeFormatter.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 12/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class TimeFormatter{
    static func millisToTimespan(millis: TimeInterval) -> String{
        let seconds = Int(millis) / 1000;
        if seconds == 0{
            return "Just now"
        }
        
        let second = "second"
        let minute = "minute"
        let hour = "hour"
        let day = "day"
        let month = "month"
        let year = "year"
        
        
        if seconds < 60 {
            return timeMessage(for: second, amount: seconds)
        }
        
        let minutes = seconds / 60
        if minutes < 60 {
            return timeMessage(for: minute, amount: minutes)
        }
        
        let hours = minutes / 60
        if hours < 24{
            return timeMessage(for: hour, amount: hours)
        }
        
        let days = hours / 24
        if days <= 30{
           return timeMessage(for: day, amount: days)
        }
        
        let months = days / 30
        if months < 12{
            return timeMessage(for: month, amount: months)
        }
        
        let years = months / 12
        return timeMessage(for: year, amount: years)
    }
    
    private static func possiblePluralSuffix(for amount : Int) -> String{
        return amount > 1 ? "s" : ""
    }
    
    private static func timeMessage(for timeUnit : String,amount : Int) -> String{
        let suffix = "ago"
        return "\(amount) \(timeUnit)\(possiblePluralSuffix(for: amount)) \(suffix)"
    }
}
