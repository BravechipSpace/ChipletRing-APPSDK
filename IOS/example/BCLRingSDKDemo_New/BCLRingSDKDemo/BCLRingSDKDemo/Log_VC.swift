//
//  Log_VC.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/3/24.
//

import BCLRingSDK
import UIKit
class Log_VC: UIViewController {
    // MARK: - 属性

    private var tableView: UITableView!
    private var logEntries: [String] = []
    private var autoRefreshTimer: Timer?
    private var autoRefreshSwitch = UISwitch()

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupUI()
        loadLogFiles()
        BDLogger.info("------------Log日志------------")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLogFiles()
        startAutoRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 如果有日志内容，且是第一次布局，滚动到底部
        if !logEntries.isEmpty && tableView.numberOfRows(inSection: 0) > 0 {
            let indexPath = IndexPath(row: logEntries.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    // MARK: - UI设置

    private func setupUI() {
        title = "日志"
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        view.addSubview(tableView)
        let clearButton = UIBarButtonItem(title: "清除", style: .plain, target: self, action: #selector(clearLogs))
        navigationItem.rightBarButtonItems = [clearButton]
        startAutoRefresh()
    }

    // MARK: - 数据加载

    private func loadLogFiles() {
        // 获取今天的日志文件路径
        let filename = "\(Date().toFormat("yyyy-MM-dd")).log"
        let logFilePath = URL(fileURLWithPath: defaultLogDirectoryPath).appendingPathComponent(filename)

        do {
            // 读取日志文件内容
            let logContent = try String(contentsOf: logFilePath, encoding: .utf8)
            // 将日志内容按行分割
            logEntries = logContent.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            tableView.reloadData()
        } catch {
            logEntries = ["无法加载日志文件: \(error.localizedDescription)"]
            tableView.reloadData()
        }
    }

    @objc private func clearLogs() {
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
            let directoryURL = URL(fileURLWithPath: defaultLogDirectoryPath)
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [.skipsHiddenFiles])

            // 删除所有.log文件
            for fileURL in fileURLs where fileURL.pathExtension == "log" {
                try fileManager.removeItem(at: fileURL)
            }
            logEntries = ["------------所有日志已清除------------"]
            tableView.reloadData()
        } catch {
            logEntries = ["清除日志文件失败: \(error.localizedDescription)"]
            tableView.reloadData()
        }
    }

    private func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                target: self,
                                                selector: #selector(autoRefreshLogs),
                                                userInfo: nil,
                                                repeats: true)
        RunLoop.current.add(autoRefreshTimer!, forMode: .common)
    }

    private func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    @objc private func autoRefreshLogs() {
        let oldCount = logEntries.count
        loadLogFiles()

        // 只有在有新日志时才滚动到底部
        if logEntries.count > oldCount && tableView.numberOfRows(inSection: 0) > 0 {
            // 滚动到最后一行（最新的日志）
            let indexPath = IndexPath(row: logEntries.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - 表格视图数据源

extension Log_VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        let logEntry = logEntries[indexPath.row]
        cell.textLabel?.text = logEntry
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        if logEntry.contains("💜") {
            cell.textLabel?.textColor = .purple // Verbose
        } else if logEntry.contains("💙") {
            cell.textLabel?.textColor = .blue // Debug
        } else if logEntry.contains("💚") {
            cell.textLabel?.textColor = .green // Info
        } else if logEntry.contains("💛") {
            cell.textLabel?.textColor = .orange // Warning
        } else if logEntry.contains("❤️") {
            cell.textLabel?.textColor = .red // Error
        } else {
            cell.textLabel?.textColor = .black // 默认
        }
        return cell
    }
}

// MARK: - 表格视图委托

extension Log_VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let logEntry = logEntries[indexPath.row]
        UIPasteboard.general.string = logEntry
        let alert = UIAlertController(title: "已复制", message: "日志已复制到剪贴板", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
