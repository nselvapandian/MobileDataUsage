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
  
  @objc func checkUsageAndShowAlert(recognizer: UITapGestureRecognizer)  {
    if recognizer.state == UIGestureRecognizer.State.ended {
      let tapLocation = recognizer.location(in: self.mainTableView)
      if let tapIndexPath = self.mainTableView.indexPathForRow(at: tapLocation) {
        
        let year = self.years?[tapIndexPath.row]
        let lRecords = self.allRecords.filter({ $0.quarter.contains(year ?? "") })
        
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
          self.showMsg(title: "Info", msg: infoText)
        } else {
          self.showMsg(title: "Info", msg: "Usages were increased each quarter")
        }
        
      }
    }
  }
  
  
  func showMsg(title : String, msg : String)
  {
    let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
    {
      action -> Void in
    })
    self.present(alertController, animated: true)
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
    
    let humanReadableString = getHumanReadableFormat(volume: volume)
    
    var quarterlyResult = true
    var quarterlyValue: CGFloat = 0.0
    
    for vol in lRecords {
      
      if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
        
        if CGFloat(truncating: n) < quarterlyValue {
          quarterlyResult = false
          break
        }
        quarterlyValue = CGFloat(truncating: n)
      }
    }
    
    if quarterlyResult {
      cell.quarterResultImageView.image = UIImage(named: "info-green.png")
    } else {
      cell.quarterResultImageView.image = UIImage(named: "info-red.png")
    }
    
    cell.volumeLabel.text = humanReadableString
    cell.period.text = year
    cell.progressBar.setProgress(Float(Double(volume)/100), animated: true)
    cell.progressBar.transform = cell.progressBar.transform.scaledBy(x: 1, y: 10)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.checkUsageAndShowAlert(recognizer:)))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.delegate = self as? UIGestureRecognizerDelegate
    self.view.addGestureRecognizer(tapGesture)
    
    return cell
  }
  
}

