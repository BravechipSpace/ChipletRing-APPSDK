//
//  LogDisplayViewController.swift
//  BCLRingSDKDemo
//
//  日志展示视图控制器
//

import UIKit
import SnapKit
import QMUIKit
import BCLRingSDK
import SwiftDate

class LogDisplayViewController: UIViewController {

    // MARK: - Properties

    /// 日志表格视图
    private let logTableView = UITableView()

    /// 标题标签
    private let titleLabel = UILabel()

    /// 关闭按钮
    private let closeButton = UIButton(type: .system)

    /// 清空按钮
    private let clearButton = UIButton(type: .system)

    /// 复制按钮
    private let copyButton = UIButton(type: .system)

    /// 自动滚动开关
    private let autoScrollSwitch = UISwitch()

    /// 容器视图
    private let containerView = UIView()

    /// 工具栏
    private let toolBar = UIView()

    /// 是否自动滚动
    private var isAutoScroll = true

    /// 定时器（用于定期更新日志）
    private var updateTimer: Timer?

    /// 日志条目数组（从文件读取的日志行）
    private var logEntries: [String] = []

    /// 单元格重用标识
    private let cellIdentifier = "LogCell"

    /// 设备信息容器视图
    private let deviceInfoView = UIView()

    /// MAC 地址标签
    private let macLabel = UILabel()

    /// RSSI 标签
    private let rssiLabel = UILabel()

    /// 连接状态标签
    private let connectionStatusLabel = UILabel()

    /// 设备信息更新定时器
    private var deviceInfoTimer: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogFiles()
        startLogUpdateTimer()
        startDeviceInfoTimer()
        updateDeviceInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLogUpdateTimer()
        stopDeviceInfoTimer()
    }

    deinit {
        stopLogUpdateTimer()
        stopDeviceInfoTimer()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // 容器视图
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)

        // 标题栏
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGray6
        containerView.addSubview(headerView)

        // 标题
        titleLabel.text = "SDK 日志"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // 关闭按钮
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)

        // 设备信息视图
        deviceInfoView.backgroundColor = UIColor.systemGray6
        deviceInfoView.layer.borderColor = UIColor.separator.cgColor
        deviceInfoView.layer.borderWidth = 0.5
        containerView.addSubview(deviceInfoView)

        // 连接状态标签
        connectionStatusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        connectionStatusLabel.textColor = .label
        connectionStatusLabel.text = "未连接"
        deviceInfoView.addSubview(connectionStatusLabel)

        // MAC 地址标签
        macLabel.font = .systemFont(ofSize: 11)
        macLabel.textColor = .secondaryLabel
        macLabel.text = "MAC: --:--:--:--:--:--"
        deviceInfoView.addSubview(macLabel)

        // RSSI 标签
        rssiLabel.font = .systemFont(ofSize: 11)
        rssiLabel.textColor = .secondaryLabel
        rssiLabel.text = "RSSI: -- dBm"
        deviceInfoView.addSubview(rssiLabel)

        // 日志表格视图
        logTableView.backgroundColor = UIColor.black
        logTableView.separatorStyle = .none
        logTableView.showsVerticalScrollIndicator = true
        logTableView.showsHorizontalScrollIndicator = false
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.register(LogTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        logTableView.estimatedRowHeight = 20
        logTableView.rowHeight = UITableView.automaticDimension
        containerView.addSubview(logTableView)

        // 工具栏
        toolBar.backgroundColor = UIColor.systemGray6
        containerView.addSubview(toolBar)

        // 清空按钮
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14)
        clearButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        toolBar.addSubview(clearButton)

        // 复制按钮
        copyButton.setTitle("复制", for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 14)
        copyButton.addTarget(self, action: #selector(copyLogs), for: .touchUpInside)
        toolBar.addSubview(copyButton)

        // 自动滚动标签
        let autoScrollLabel = UILabel()
        autoScrollLabel.text = "自动滚动"
        autoScrollLabel.font = .systemFont(ofSize: 14)
        autoScrollLabel.textColor = .label
        toolBar.addSubview(autoScrollLabel)

        // 自动滚动开关
        autoScrollSwitch.isOn = isAutoScroll
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollChanged), for: .valueChanged)
        toolBar.addSubview(autoScrollSwitch)

        // 设置约束
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(80)
            make.bottom.equalToSuperview().offset(-80)
        }

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(30)
        }

        deviceInfoView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        connectionStatusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(15)
        }

        macLabel.snp.makeConstraints { make in
            make.top.equalTo(connectionStatusLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(15)
        }

        rssiLabel.snp.makeConstraints { make in
            make.centerY.equalTo(macLabel)
            make.left.equalTo(macLabel.snp.right).offset(20)
        }

        toolBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }

        logTableView.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }

        clearButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }

        copyButton.snp.makeConstraints { make in
            make.left.equalTo(clearButton.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }

        autoScrollSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }

        autoScrollLabel.snp.makeConstraints { make in
            make.right.equalTo(autoScrollSwitch.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

        // 添加点击手势到背景
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Log Management

    private func loadLogFiles() {
        // 获取今天的日志文件路径
        DispatchQueue.global(qos: .background).async { [weak self] in
            let filename = "\(Date().toFormat("yyyy-MM-dd")).log"
            let logFilePath = URL(fileURLWithPath: BDLogConfig.currentLogDirectoryPath).appendingPathComponent(filename)

            do {
                // 读取日志文件内容
                let logContent = try String(contentsOf: logFilePath, encoding: .utf8)
                // 将日志内容按行分割
                let entries = logContent.components(separatedBy: .newlines)
                    .filter { !$0.isEmpty }

                DispatchQueue.main.async {
                    self?.logEntries = entries
                    self?.updateLogDisplayFromEntries()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.logEntries = ["无法加载日志文件: \(error.localizedDescription)"]
                    self?.updateLogDisplayFromEntries()
                }
            }
        }
    }

    private func updateLogDisplayFromEntries() {
        // 刷新表格视图
        logTableView.reloadData()

        if isAutoScroll && !logEntries.isEmpty {
            // 滚动到底部
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.logEntries.count - 1, section: 0)
                self.logTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    private func startLogUpdateTimer() {
        stopLogUpdateTimer()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLogsIncrementally()
        }
        RunLoop.current.add(updateTimer!, forMode: .common)
    }

    private func stopLogUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateLogsIncrementally() {
        // 增量更新日志
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let filename = "\(Date().toFormat("yyyy-MM-dd")).log"
            let logFilePath = URL(fileURLWithPath: BDLogConfig.currentLogDirectoryPath).appendingPathComponent(filename)

            do {
                // 读取日志文件内容
                let logContent = try String(contentsOf: logFilePath, encoding: .utf8)
                // 将日志内容按行分割
                let newEntries = logContent.components(separatedBy: .newlines)
                    .filter { !$0.isEmpty }

                DispatchQueue.main.async {
                    let oldCount = self.logEntries.count
                    let hasNewLogs = newEntries.count > oldCount

                    if hasNewLogs {
                        // 只有新增的日志才添加
                        let newLogsCount = newEntries.count - oldCount
                        let newLogs = Array(newEntries.suffix(newLogsCount))

                        // 添加新日志
                        self.logEntries.append(contentsOf: newLogs)

                        // 插入新行而不是重新加载整个表格
                        let indexPaths = (oldCount..<self.logEntries.count).map { IndexPath(row: $0, section: 0) }
                        self.logTableView.insertRows(at: indexPaths, with: .none)

                        // 自动滚动到底部
                        if self.isAutoScroll && !self.logEntries.isEmpty {
                            let indexPath = IndexPath(row: self.logEntries.count - 1, section: 0)
                            self.logTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    } else if newEntries.count != oldCount {
                        // 如果日志被清空或变少了，需要重新加载
                        self.logEntries = newEntries
                        self.logTableView.reloadData()
                    }
                }
            } catch {
                // 忽略错误，不中断定时器
            }
        }
    }

    // MARK: - Device Info Management

    private func startDeviceInfoTimer() {
        stopDeviceInfoTimer()
        deviceInfoTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDeviceInfo()
        }
        RunLoop.current.add(deviceInfoTimer!, forMode: .common)
    }

    private func stopDeviceInfoTimer() {
        deviceInfoTimer?.invalidate()
        deviceInfoTimer = nil
    }

    private func updateDeviceInfo() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let device = BCLRingManager.shared.currentConnectedDevice {
                // 设备已连接
                self.connectionStatusLabel.text = "已连接: \(device.peripheralName ?? "未知设备")"
                self.connectionStatusLabel.textColor = .systemGreen

                // MAC 地址
                if let mac = device.macAddress, !mac.isEmpty {
                    self.macLabel.text = "MAC: \(mac)"
                } else {
                    self.macLabel.text = "MAC: 获取中..."
                }

                // RSSI
                if let rssi = device.rssi {
                    self.rssiLabel.text = "RSSI: \(rssi) dBm"

                    // 根据信号强度设置颜色
                    if Int(rssi) >= -50 {
                        self.rssiLabel.textColor = .systemGreen  // 信号极好
                    } else if Int(rssi) >= -70 {
                        self.rssiLabel.textColor = .systemBlue   // 信号良好
                    } else if Int(rssi) >= -85 {
                        self.rssiLabel.textColor = .systemOrange // 信号一般
                    } else {
                        self.rssiLabel.textColor = .systemRed    // 信号较差
                    }
                } else {
                    self.rssiLabel.text = "RSSI: -- dBm"
                    self.rssiLabel.textColor = .secondaryLabel
                }
            } else {
                // 设备未连接
                self.connectionStatusLabel.text = "未连接"
                self.connectionStatusLabel.textColor = .systemGray
                self.macLabel.text = "MAC: --:--:--:--:--:--"
                self.macLabel.textColor = .secondaryLabel
                self.rssiLabel.text = "RSSI: -- dBm"
                self.rssiLabel.textColor = .secondaryLabel
            }
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func clearLogs() {
        // 显示确认对话框
        let alert = UIAlertController(title: "清除日志",
                                      message: "确定要清除所有日志文件吗？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            self?.deleteAllLogFiles()
        })
        present(alert, animated: true)
    }

    private func deleteAllLogFiles() {
        do {
            let fileManager = FileManager.default
            let directoryURL = URL(fileURLWithPath: BDLogConfig.currentLogDirectoryPath)
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [.skipsHiddenFiles])

            // 删除所有.log文件
            for fileURL in fileURLs where fileURL.pathExtension == "log" {
                try fileManager.removeItem(at: fileURL)
            }

            // 清空显示
            logEntries = ["------------所有日志已清除------------"]
            updateLogDisplayFromEntries()
            QMUITips.showSucceed("所有日志已清除")
        } catch {
            logEntries = ["清除日志文件失败: \(error.localizedDescription)"]
            updateLogDisplayFromEntries()
            QMUITips.showError("清除失败: \(error.localizedDescription)")
        }
    }

    @objc private func copyLogs() {
        let allLogs = logEntries.joined(separator: "\n")
        UIPasteboard.general.string = allLogs
        QMUITips.showSucceed("日志已复制到剪贴板")
    }

    @objc private func autoScrollChanged() {
        isAutoScroll = autoScrollSwitch.isOn
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let containerFrame = containerView.frame

        // 判断点击位置是否在容器外
        if !containerFrame.contains(location) {
            dismiss(animated: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LogDisplayViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 只有点击背景时才响应
        return touch.view == view
    }
}

// MARK: - UITableViewDataSource

extension LogDisplayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LogTableViewCell
        let logEntry = logEntries[indexPath.row]
        cell.configure(with: logEntry)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LogDisplayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 复制选中的日志行到剪贴板
        let logEntry = logEntries[indexPath.row]
        UIPasteboard.general.string = logEntry
        QMUITips.showSucceed("该行日志已复制到剪贴板")
    }
}

// MARK: - Custom Table View Cell

class LogTableViewCell: UITableViewCell {

    private let logLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none

        logLabel.font = UIFont(name: "Menlo", size: 11) ?? .systemFont(ofSize: 11)
        logLabel.numberOfLines = 0
        logLabel.lineBreakMode = .byCharWrapping
        contentView.addSubview(logLabel)

        logLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8))
        }
    }

    func configure(with logEntry: String) {
        // 根据日志级别设置颜色
        let color: UIColor
        if logEntry.contains("💜") {
            color = .systemPurple // Verbose
        } else if logEntry.contains("💙") {
            color = .systemBlue // Debug
        } else if logEntry.contains("💚") {
            color = .systemGreen // Info
        } else if logEntry.contains("💛") {
            color = .orange // Warning
        } else if logEntry.contains("❤️") {
            color = .systemRed // Error
        } else {
            color = .green // 默认
        }

        logLabel.text = logEntry
        logLabel.textColor = color
    }
}
