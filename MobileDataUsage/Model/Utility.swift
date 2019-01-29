//
//  Utility.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation
import UIKit

func performOnMainThread(_ block: @escaping ()->Void) {
  DispatchQueue.main.async(execute: block)
}

func getHumanReadableFormat(volume: CGFloat) -> String {
  var humanReadableValue: Double = 0.0
  var humanReadableString = ""
  
  if volume > 1 {
    humanReadableString = String(format: "%.2f PB", Double(volume))
  } else {
    
    if volume < 1 {
      humanReadableString = String(format: "%.2f TB", Double(volume) * 1024)
      humanReadableValue = Double(volume) * 1024
    }
    if humanReadableValue < 1 {
      humanReadableString = String(format: "%.2f GB", Double(humanReadableValue) * 1024)
      humanReadableValue = Double(humanReadableValue) * 1024
    }
    if humanReadableValue < 1 {
      humanReadableString = String(format: "%.2f MB", Double(humanReadableValue) * 1024)
      humanReadableValue = Double(humanReadableValue) * 1024
    }
    if humanReadableValue < 1 {
      humanReadableString = String(format: "%.2f Bytes", Double(humanReadableValue) * 1024)
      humanReadableValue = Double(humanReadableValue) * 1024
    }
    
  }
  return humanReadableString
}
