//
//  TimeZoneList_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/8/22.
//

import BCLRingSDK
import QMUIKit
import RxSwift
import SwiftDate
import UIKit

struct TimeZoneItem {
    let name: String
    let identifier: String
    let iOSTimeZone: TimeZone
    let bclTimeZone: BCLRingTimeZone
    let utcOffset: String
    let gmtOffset: String
    let currentTime: String
    let bclRawValue: String
}

class TimeZoneList_VC: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TimeZoneCell")
        table.separatorStyle = .singleLine
        table.rowHeight = 160
        return table
    }()
    
    private var timeZoneItems: [TimeZoneItem] = []
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTimeZones()
    }
    
    private func setupUI() {
        title = "时区列表"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "获取当前",
                style: .plain,
                target: self,
                action: #selector(getCurrentTimeZone)
            )
        ]
    }
    
    private func loadTimeZones() {
        var items: [TimeZoneItem] = []
        
        let knownTimeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
        
        for identifier in knownTimeZones {
            guard let iosTimeZone = TimeZone(identifier: identifier) else { continue }
            
            let currentDate = Date()
            let offsetSeconds = iosTimeZone.secondsFromGMT(for: currentDate)
            let offsetHours = offsetSeconds / 3600
            let offsetMinutes = abs(offsetSeconds % 3600) / 60
            
            // UTC偏移格式
            let utcOffsetSign = offsetSeconds >= 0 ? "+" : "-"
            let utcOffset = offsetMinutes == 0 
                ? "UTC\(utcOffsetSign)\(abs(offsetHours))"
                : "UTC\(utcOffsetSign)\(abs(offsetHours)):\(String(format: "%02d", offsetMinutes))"
            
            // GMT偏移格式
            let gmtOffsetSign = offsetSeconds >= 0 ? "+" : "-"
            let gmtOffset = offsetMinutes == 0 
                ? "GMT\(gmtOffsetSign)\(abs(offsetHours))"
                : "GMT\(gmtOffsetSign)\(abs(offsetHours)):\(String(format: "%02d", offsetMinutes))"
            
            // 当前时间格式化
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            timeFormatter.timeZone = iosTimeZone
            let currentTime = timeFormatter.string(from: currentDate)
            
            let cityName = extractCityName(from: identifier)
            
            // 为当前遍历的时区计算对应的BCL时区
            let bclTimeZone = BCLRingTimeZone.calculateBCLTimeZone(for: iosTimeZone)
            let bclRawValue = "0x\(String(format: "%02X", bclTimeZone.rawValue))"
            
            let item = TimeZoneItem(
                name: cityName,
                identifier: identifier,
                iOSTimeZone: iosTimeZone,
                bclTimeZone: bclTimeZone,
                utcOffset: utcOffset,
                gmtOffset: gmtOffset,
                currentTime: currentTime,
                bclRawValue: bclRawValue
            )
            items.append(item)
        }
        
        timeZoneItems = items
        tableView.reloadData()
    }
    
    private func extractCityName(from identifier: String) -> String {
        let components = identifier.components(separatedBy: "/")
        if components.count > 1 {
            return components.last?.replacingOccurrences(of: "_", with: " ") ?? identifier
        }
        return identifier
    }
    
    @objc private func getCurrentTimeZone() {
        // 使用新的详细时区信息API
        let (currentBCLTimeZone, timeZoneInfo) = BCLRingTimeZone.getCurrentSystemTimeZoneInfo()
        let currentIOSTimeZone = TimeZone.current
        
        // 格式化当前时间
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timeFormatter.timeZone = currentIOSTimeZone
        let currentTime = timeFormatter.string(from: Date())
        
        // 格式化下次切换时间
        var nextTransitionStr = "无"
        if let nextTransition = timeZoneInfo.nextTransition {
            let transitionFormatter = DateFormatter()
            transitionFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            transitionFormatter.timeZone = currentIOSTimeZone
            nextTransitionStr = transitionFormatter.string(from: nextTransition)
        }
        
        let bclRawValue = "0x\(String(format: "%02X", currentBCLTimeZone.rawValue))"
        
        let alert = UIAlertController(
            title: "当前系统时区详情（基于系统API）",
            message: """
            === 基本信息 ===
            时区标识：\(timeZoneInfo.identifier)
            当前时间：\(currentTime)
            时区缩写：\(currentIOSTimeZone.abbreviation() ?? "N/A")
            
            === 偏移详情 ===
            总偏移：\(timeZoneInfo.offsetDescription)
            标准偏移：UTC\(timeZoneInfo.standardOffsetHours >= 0 ? "+" : "")\(Int(timeZoneInfo.standardOffsetHours))
            夏令时状态：\(timeZoneInfo.daylightSavingDescription)
            下次切换：\(nextTransitionStr)
            
            === BCLRingSDK信息 ===
            时区枚举：\(currentBCLTimeZone)
            偏移值：\(currentBCLTimeZone.timeZoneOffset)
            RawValue：\(bclRawValue)
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TimeZoneList_VC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeZoneItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TimeZoneCell")
        let item = timeZoneItems[indexPath.row]
        
        // 主标题：城市名称
        cell.textLabel?.text = "🌍 \(item.name)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.textLabel?.textColor = .label
        
        // 详细信息：包含所有时区信息
        let detailText = """
        📍 时区标识：\(item.identifier)
        🕐 当前时间：\(item.currentTime)
        🌐 UTC偏移：\(item.utcOffset)    GMT偏移：\(item.gmtOffset)
        💍 BCL时区：\(item.bclTimeZone) (偏移:\(item.bclTimeZone.timeZoneOffset))
        🔢 RawValue：\(item.bclRawValue)
        """
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        // 高亮当前系统时区
        if item.iOSTimeZone.identifier == TimeZone.current.identifier {
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            cell.textLabel?.textColor = .systemBlue
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            cell.layer.cornerRadius = 8
        } else {
            cell.backgroundColor = .systemBackground
            cell.textLabel?.textColor = .label
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TimeZoneList_VC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 移除选中效果，因为所有信息已经在cell中显示
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "共 \(timeZoneItems.count) 个时区"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
}
