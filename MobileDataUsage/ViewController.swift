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
  var reachability: Reachability?
  let hostNames = [nil, "google.com", "invalidhost"]
  var hostIndex = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startHost(at: 0)
    self.fetchMobileUsageData()
  }
  
  private func fetchMobileUsageData() {
    NetworkManager.sharedManager.getMobileUsageData(requestType: HTTPRequestType.GET, success: { (data, response) in
      
      do {
        
        let dataUsage = try? JSONDecoder().decode(DataUsage.self, from: data)
        
        UserDefaults.standard.set(data, forKey: "usage")
        UserDefaults.standard.synchronize()
        
        self.allRecords = dataUsage?.result.records ?? []
        self.years = Array(Set(self.allRecords.compactMap({ $0.quarter.components(separatedBy: "-").first }))).sorted()
        
        performOnMainThread {
          self.mainTableView.reloadData()
        }
        print("Fetch USage API Success")
      }
    }) { (error) in
      print("error")
    }
  }
  
  private func fetchMobileUSageFromLocal() {
    
    let data1 = UserDefaults.standard.object(forKey: "usage") as? Data
    let dataUsage1 = try? JSONDecoder().decode(DataUsage.self, from: data1 ?? Data())
    
    self.allRecords = dataUsage1?.result.records ?? []
    self.years = Array(Set(self.allRecords.compactMap({ $0.quarter.components(separatedBy: "-").first }))).sorted()
    
    performOnMainThread {
      self.mainTableView.reloadData()
    }
  }
  
  
  func startHost(at index: Int) {
    stopNotifier()
    setupReachability(hostNames[index], useClosures: true)
    startNotifier()
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      self.startHost(at: (index + 1) % 3)
    }
  }
  
  func setupReachability(_ hostName: String?, useClosures: Bool) {
    let reachability: Reachability?
    if let hostName = hostName {
      reachability = Reachability(hostname: hostName)
    } else {
      reachability = Reachability()
    }
    self.reachability = reachability
    
    if useClosures {
      reachability?.whenReachable = { reachability in
        self.updateWhenReachable(reachability)
      }
      reachability?.whenUnreachable = { reachability in
        self.updateWhenNotReachable(reachability)
      }
    } else {
      NotificationCenter.default.addObserver(self,
        selector: #selector(reachabilityChanged(_:)),
        name: .reachabilityChanged,
        object: reachability
      )
    }
  }
  
  func startNotifier() {
    print("--- start notifier")
    do {
      try reachability?.startNotifier()
    } catch {
      return
    }
  }
  
  func stopNotifier() {
    print("--- stop notifier")
    reachability?.stopNotifier()
    NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    reachability = nil
  }
  
  func updateWhenReachable(_ reachability: Reachability) {
    print("reachable")
    self.fetchMobileUsageData()
  }
  
  func updateWhenNotReachable(_ reachability: Reachability) {
    print("Not Reachable")
    self.fetchMobileUSageFromLocal()
  }
  
  @objc func reachabilityChanged(_ note: Notification) {
    let reachability = note.object as! Reachability
    
    if reachability.connection != .none {
      updateWhenReachable(reachability)
    } else {
      updateWhenNotReachable(reachability)
    }
  }
  
  deinit {
    stopNotifier()
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
    
    //Calculating the total usage
    for vol in lRecords {
      
      if let n = NumberFormatter().number(from: vol.volumeOfMobileData) {
        volume += CGFloat(truncating: n)
      }
    }
    
    let humanReadableString = getHumanReadableFormat(volume: volume)
    
    var quarterlyResult = true
    var quarterlyValue: CGFloat = 0.0
    
    //Checking for quarterly usage drop
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
    //cell.progressBar.transform = cell.progressBar.transform.scaledBy(x: 1, y: 7)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.checkUsageAndShowAlert(recognizer:)))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.delegate = self as? UIGestureRecognizerDelegate
    self.view.addGestureRecognizer(tapGesture)
    
    return cell
  }
}

