//
//  MobileDataUsageTests.swift
//  MobileDataUsageTests
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import XCTest
@testable import MobileDataUsage

class MobileDataUsageTests: XCTestCase {
  
  var years: [String]?
  var allRecords = [Record]()
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    self.fetchMobileUSageFromLocal()
    
    self.checkQuarterlyUsageDeviationForTheYear(year: "2005")
    self.checkQuarterlyUsageDeviationForTheYear(year: "2100")
    self.checkQuarterlyUsageDeviationForTheYear(year: "2011")
    
    self.getYearlyUsageDataForTheYear(year: "2005")
    self.getYearlyUsageDataForTheYear(year: "2009")
    self.getYearlyUsageDataForTheYear(year: "2015")
    self.getYearlyUsageDataForTheYear(year: "2105")
    
    self.getTotalUsageData()
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  func fetchMobileUSageFromLocal() {
    
    let data = UserDefaults.standard.object(forKey: "usage") as? Data
    let dataUsage = try? JSONDecoder().decode(DataUsage.self, from: data ?? Data())
    
    self.allRecords = dataUsage?.result.records ?? []
    self.years = Array(Set(allRecords.compactMap({ $0.quarter.components(separatedBy: "-").first }))).sorted()
    
    print(self.allRecords)
    print(self.years as Any)
  }
  
  func checkQuarterlyUsageDeviationForTheYear(year: String) {
    
    let lRecords = self.allRecords.filter({ $0.quarter.contains(year ) })
    
    guard lRecords.count > 0 else {
      print("No deviation found or the entered year is wrong")
      return
    }
    
    var quarter = ""
    var quarterlyValue: CGFloat = 0.0
    var infoText = ""
    
    for vol in lRecords {
      
      if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
        if CGFloat(truncating: n) < quarterlyValue {
          
          if infoText.count > 0 {
            infoText = infoText + ", \(vol.quarter) usage is less compared to \(quarter)"
          } else {
            infoText = infoText + "\(vol.quarter) usage is less compared to \(quarter)"
          }
        }
        quarter = vol.quarter
        quarterlyValue = CGFloat(truncating: n)
      }
    }
    
    if infoText.count > 0 {
      print("Deviation for the year \(year) is : \(infoText)")
    } else {
      print("Usages were increased each quarter for the year \(year)")
    }
  }
  
  func getYearlyUsageDataForTheYear(year: String) {
    
    let lRecords = self.allRecords.filter({ $0.quarter.contains(year) })
    var volume: CGFloat = 0.0
    
    //Calculating the total usage
    for vol in lRecords {
      
      if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
        volume += CGFloat(truncating: n)
      }
    }
    
    if volume == 0 {
      print("The usage is 0 or year entered is wrong")
    } else {
      print("Yearly usage for the year \(year) is \(getHumanReadableFormat(volume: volume))")
    }
    
  }
  
  func getTotalUsageData() {
    
    var totalVolume: CGFloat = 0.0
    
    for year in self.years ?? [] {
      
      let lRecords = self.allRecords.filter({ $0.quarter.contains(year) })
      
      //Calculating the total usage
      for vol in lRecords {
        
        if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
          totalVolume += CGFloat(truncating: n)
        }
      }
    }
    print("\(getHumanReadableFormat(volume: totalVolume))")
  }
  
}
