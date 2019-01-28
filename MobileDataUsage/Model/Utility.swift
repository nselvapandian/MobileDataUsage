//
//  Utility.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation

func performOnMainThread(_ block: @escaping ()->Void) {
  DispatchQueue.main.async(execute: block)
}
