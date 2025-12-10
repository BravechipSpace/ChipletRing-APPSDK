import Foundation

// 时区调试工具
class TimeZoneDebugger {
    
    /// 打印详细的时区调试信息
    static func debugCurrentTimeZone() {
        let currentTimeZone = TimeZone.current
        let currentDate = Date()
        
        print("=== 时区调试信息 ===")
        print("时区标识符: \(currentTimeZone.identifier)")
        print("时区本地化名称: \(currentTimeZone.localizedName(for: .standard, locale: .current) ?? "N/A")")
        print("时区缩写: \(currentTimeZone.abbreviation() ?? "N/A")")
        
        // 当前时间的偏移
        let currentOffsetSeconds = currentTimeZone.secondsFromGMT(for: currentDate)
        let currentOffsetHours = Double(currentOffsetSeconds) / 3600.0
        print("当前偏移秒数: \(currentOffsetSeconds)")
        print("当前偏移小时数: \(currentOffsetHours)")
        
        // 1月1日的偏移（标准时区偏移）
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let januaryFirst = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? currentDate
        let standardOffsetSeconds = currentTimeZone.secondsFromGMT(for: januaryFirst)
        let standardOffsetHours = Double(standardOffsetSeconds) / 3600.0
        print("标准偏移秒数 (1月1日): \(standardOffsetSeconds)")
        print("标准偏移小时数 (1月1日): \(standardOffsetHours)")
        
        // 是否是夏令时
        let isDaylightSaving = currentTimeZone.isDaylightSavingTime(for: currentDate)
        print("是否夏令时: \(isDaylightSaving)")
        
        // 夏令时偏移
        let daylightSavingOffset = currentTimeZone.daylightSavingTimeOffset(for: currentDate)
        print("夏令时偏移秒数: \(daylightSavingOffset)")
        
        // 格式化时间显示
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z (zzzz)"
        formatter.timeZone = currentTimeZone
        print("当前时间: \(formatter.string(from: currentDate))")
        
        // UTC时间
        formatter.timeZone = TimeZone(identifier: "UTC")
        print("UTC时间: \(formatter.string(from: currentDate))")
        
        print("================")
    }
    
    /// 测试特定时区标识符
    static func testSpecificTimeZone(_ identifier: String) {
        guard let timeZone = TimeZone(identifier: identifier) else {
            print("无法创建时区: \(identifier)")
            return
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let januaryFirst = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? currentDate
        
        let currentOffsetSeconds = timeZone.secondsFromGMT(for: currentDate)
        let standardOffsetSeconds = timeZone.secondsFromGMT(for: januaryFirst)
        
        print("=== 测试时区: \(identifier) ===")
        print("当前偏移: \(Double(currentOffsetSeconds) / 3600.0) 小时")
        print("标准偏移: \(Double(standardOffsetSeconds) / 3600.0) 小时")
        print("是否夏令时: \(timeZone.isDaylightSavingTime(for: currentDate))")
        print("============================")
    }
    
    /// 测试卢布尔雅那时区
    static func testLjubljanaTimeZone() {
        print("=== 卢布尔雅那时区测试 ===")
        
        // 可能的卢布尔雅那时区标识符
        let possibleIdentifiers = [
            "Europe/Ljubljana",
            "Europe/Belgrade", // 塞尔维亚贝尔格莱德（相同时区）
            "Europe/Zagreb",   // 克罗地亚萨格勒布（相同时区）
            "Europe/Vienna",   // 奥地利维也纳（相同时区）
            "Europe/Budapest"  // 匈牙利布达佩斯（相同时区）
        ]
        
        for identifier in possibleIdentifiers {
            testSpecificTimeZone(identifier)
        }
        
        print("========================")
    }
    
    /// 测试修改后的时区计算逻辑
    static func testUpdatedTimeZoneLogic() {
        print("=== 测试更新后的时区计算逻辑 ===")
        
        // 测试卢布尔雅那时区
        if let ljubljanaTimeZone = TimeZone(identifier: "Europe/Ljubljana") {
            print("测试 Europe/Ljubljana:")
            let currentDate = Date()
            let currentOffset = Double(ljubljanaTimeZone.secondsFromGMT(for: currentDate)) / 3600.0
            print("  当前实际偏移: \(currentOffset) 小时")
            print("  是否夏令时: \(ljubljanaTimeZone.isDaylightSavingTime(for: currentDate))")
            
            // 模拟新的计算逻辑
            print("  新逻辑计算结果: East1 (标准时区，设备端处理夏令时)")
        }
        
        // 测试其他夏令时区域
        let testTimeZones = [
            "Europe/Berlin": "中欧时间",
            "Europe/London": "西欧时间", 
            "America/New_York": "美国东部时间",
            "Australia/Sydney": "澳洲东部时间"
        ]
        
        for (identifier, description) in testTimeZones {
            if let timeZone = TimeZone(identifier: identifier) {
                let currentDate = Date()
                let currentOffset = Double(timeZone.secondsFromGMT(for: currentDate)) / 3600.0
                let isDST = timeZone.isDaylightSavingTime(for: currentDate)
                
                print("\n测试 \(identifier) (\(description)):")
                print("  当前实际偏移: \(currentOffset) 小时")
                print("  是否夏令时: \(isDST)")
            }
        }
        
        print("\n================================")
    }
}