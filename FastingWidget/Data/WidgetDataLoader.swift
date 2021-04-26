//
//  WidgetDataLoader.swift
//  FastingWidgetExtension
//
//  Created by Zach McGaughey on 4/26/21.
//

import Foundation
import OSLog
import SharedData

enum WidgetDataLoader {
  
  static let sharedDataFileURL: URL = {
    let appGroupIdentifier = "group.com.zachmcgaughey.Fast"
    if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
      return url.appendingPathComponent("SharedData.json")
    }
    else {
      preconditionFailure("Expected a valid app group container")
    }
  }()
  
  static func loadTimeline() -> [WidgetEntry] {
    
    let data = loadSharedData()
    
    switch data {
    case .active(let fastInfo):
      return getActiveTimeline(from: fastInfo)
      
    case .idle(let lastFast):
      return getIdleTimeline(with: lastFast)
    }
    
  }
  
  static func loadSharedData() -> SharedWidgetDataType {
    
    do {
      let data: Data = try Data(contentsOf: Self.sharedDataFileURL)
      let widgetData: SharedWidgetDataType = try JSONDecoder().decode(SharedWidgetDataType.self, from: data)
      return widgetData
      
    } catch {
      Logger().error("Error loading widget data: \(error.localizedDescription)")
      return SharedWidgetDataType.idle(lastFastDate: nil)
    }
    
  }
  
  private static func getIdleTimeline(with lastFastDate: Date?) -> [WidgetEntry] {
    [WidgetEntry(date: Date(), data: .idle(lastFastDate: lastFastDate))]
  }
  
  private static func getActiveTimeline(from fastInfo: SharedFastInfo) -> [WidgetEntry] {
    
    var returnInfo: [WidgetEntry] = []
    
    // Figure out how long each "percent" interval is
    let percentInterval: TimeInterval = fastInfo.targetInterval / 100
    
    // Calculate how many ticks we have until we hit 100%
    let currentPercent: Int = Int(Date().timeIntervalSince(fastInfo.startDate) / fastInfo.targetInterval * 100)
    
    // If over 100% we don't need further updates
    if currentPercent > 100 {
      return [WidgetEntry(date: Date(), data: .active(fastInfo: fastInfo))]
    }
    
    let now: Date = Date()
    // How many updates will we need to perform. Add one for good measure
    // to make sure we end above 100%
    let requiredTicks: Int = Int(100 - currentPercent) + 1
    
    for tick in 0...requiredTicks {
      let targetDate: Date = now.addingTimeInterval(TimeInterval(tick) * percentInterval)
      let entry = WidgetEntry(date: targetDate, data: .active(fastInfo: fastInfo))
      returnInfo.append(entry)
    }
    
    return returnInfo
  }
  
}
