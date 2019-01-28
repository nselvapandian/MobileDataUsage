//
//  ViewController.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
  
  @IBOutlet weak var mainTableView: UITableView!
  
  var years: [String]?
  var allRecords = [Record]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    NetworkManager.sharedManager.getMobileUsageData(requestType: HTTPRequestType.GET, success: { (data, response) in
      
      do {
        
        let dataUsage = try? JSONDecoder().decode(DataUsage.self, from: data)
        
        self.allRecords = dataUsage?.result.records ?? []
        self.years = Array(Set(self.allRecords.compactMap({ $0.quarter.components(separatedBy: "-").first }))).sorted()
        
        performOnMainThread {
          self.mainTableView.reloadData()
        }
        print("Success")
      }
      
      
    }) { (error) in
      print("error")
    }
    
  }
  
  
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    
    return self.years?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "UsageTableViewCell", for: indexPath) as! UsageTableViewCell
    
    let year = self.years?[indexPath.row]
    
    let lRecords = self.allRecords.filter({ $0.quarter.contains(year ?? "") })
    var volume: CGFloat = 0.0
    
    
    for vol in lRecords {
      
      if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
        volume += CGFloat(truncating: n)
      }
    }
    
    cell.volumeLabel.text = String(format: "%.5f", Double(volume))
    cell.period.text = year
    cell.progressBar.setProgress(Float(Double(volume)/100), animated: true)
    cell.progressBar.transform = cell.progressBar.transform.scaledBy(x: 1, y: 10)
    
    return cell
  }
  
}

