//
//  NetworkManager.swift
//  MobileDataUsage
//
//  Created by Selva Pandian N on 28/01/19.
//  Copyright © 2019 Selva Pandian N. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()
public typealias SuccessData = (_ data: Data,_ response: URLResponse?)->()
public typealias FailureData = (_ error: Error)->()

class NetworkManager {
  
  static let sharedManager = NetworkManager()
  private init() {}
  
  let sharedSession = URLSession.shared
  private var task: URLSessionTask?
  
  private func createAPIRequest(request: URLRequest ,completion: @escaping NetworkRouterCompletion) {
    
    task = sharedSession.dataTask(with: request, completionHandler: { data, response, error in
      
      if let res = response as? HTTPURLResponse, res.statusCode == HTTPResponseCode.success {
        completion(data, response, nil)
      } else {
        completion(nil, nil, error)
      }
    })
    self.task?.resume()
  }
  
  func getMobileUsageData(requestType: String, success: @escaping SuccessData, failure: @escaping FailureData) {
    
    self.cancelAllTasks()
    
    let url = "\(kBaseUrl)/datastore_search?resource_id=\(kResourceID)&limit=\(kLimit)"
    
    var request = URLRequest(url: URL(string : url) ?? URL(string: "")!)
    request.httpMethod = requestType
    
    self.createAPIRequest(request: request) { (data, response, error) in
      if error == nil {
        success(data ?? Data(), response)
      } else {
        failure(error ?? Error.self as! Error)
      }
    }
  }
  
  func cancel() {
    self.task?.cancel()
  }
  
  func cancelAllTasks() {
    
    self.sharedSession.getAllTasks { (tasks) in
      for task in tasks {
        task.cancel()
      }
    }
    self.sharedSession.invalidateAndCancel()
  }
  
}
