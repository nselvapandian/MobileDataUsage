//
//  Constants.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation
import UIKit

let kAPP_JSON = "application/json"
let kCONTENT_TYPE = "Content-Type"
let kACCEPT = "Accept"
let kHTTPTYPE_POST = "POST"
let kHTTPTYPE_GET = "GET"

let NetworkManagerObject = NetworkManager.sharedManager


struct HTTPRequestType {
  static let GET = "GET"
  static let POST = "POST"
  static let DELETE = "DELETE"
  static let PUT = "PUT"
}

struct HTTPResponseCode {
  static let success = 200
}

let kResourceID = "a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
let kLimit = 100
let kBaseUrl = "https://data.gov.sg/api/action"
