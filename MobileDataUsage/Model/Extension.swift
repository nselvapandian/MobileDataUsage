//
//  Extension.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation

extension Data {
  
  public func convertDataToDict() -> [String: AnyObject] {
    do {
      guard let dict = try JSONSerialization.jsonObject(with: self, options: [JSONSerialization.ReadingOptions.mutableContainers]) as? [String: AnyObject] else {
        print("error trying to convert data to JSON")
        return [:]
      }
      return dict
    }
    catch{
      return [:]
    }
  }
}
