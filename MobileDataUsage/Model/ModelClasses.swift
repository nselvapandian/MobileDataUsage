//
//  ModelClasses.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation

struct DataUsage: Codable {
  let help: String
  let success: Bool
  let result: Result
}

struct Result: Codable {
  let resourceID: String
  let fields: [Field]
  let records: [Record]
  let links: Links
  let limit, total: Int
  
  enum CodingKeys: String, CodingKey {
    case resourceID = "resource_id"
    case fields, records
    case links = "_links"
    case limit, total
  }
}

struct Field: Codable {
  let type, id: String
}

struct Links: Codable {
  let start, next: String
}

struct Record: Codable {
  let volumeOfMobileData, quarter: String
  let id: Int
  
  enum CodingKeys: String, CodingKey {
    case volumeOfMobileData = "volume_of_mobile_data"
    case quarter
    case id = "_id"
  }
}
