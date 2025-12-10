//
//  FileListDialog.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/27.
//

import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

// MARK: - 文件信息模型
struct FileInfoModel {
    let fileName: String
    let userId: String?
    let fileDate: String?
    let fileSize: Int?
    let fileType: String?
    var isSelected: Bool = false

    var fileTypeDescription: String {
        guard let type = fileType else { return "未知" }
        switch type {
        case "1": return "三轴数据"
        case "2": return "六轴数据"
        case "3": return "PPG(红外+红色+三轴)"
        case "4": return "PPG(绿色)"
        case "5": return "PPG(红外)"
        case "6": return "温度数据"
        case "7": return "综合数据"
        case "8": return "ADPCM音频"
        case "9": return "OPUS音频"
        case "10", "A", "a": return "攀岩日志"
        default: return "未知类型"
        }
    }

    var fileSizeDescription: String {
        guard let size = fileSize else { return "0 KB" }
        let kb = Double(size) / 1024.0
        if kb < 1024 {
            return String(format: "%.2f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.2f MB", mb)
        }
    }
}

// MARK: - 文件列表对话框
class FileListDialog: UIView {
    var downloadButtonCallback: ((_ selectedFiles: [String]) -> Void)?

    private var fileList: [FileInfoModel] = []

    convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, files: [FileInfoModel]) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
        self.fileList = files
        tableView.reloadData()
        updateSelectAllButton()
        updateDownloadButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(selectAllButton)
        addSubview(tableView)
        addSubview(bottomView)
        bottomView.addSubview(downloadButton)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }

        selectAllButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectAllButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        downloadButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }

    // MARK: - 懒加载

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "文件列表"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var selectAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("全选", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(FileListCell.self, forCellReuseIdentifier: "FileListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        return tableView
    }()

    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        // 添加顶部分割线
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray.withAlphaComponent(0.3)
        view.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()

    lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("下载选中的文件 (0)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Actions

    @objc func closeButtonTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    @objc func selectAllButtonTapped() {
        let allSelected = fileList.allSatisfy { $0.isSelected }
        for i in 0..<fileList.count {
            fileList[i].isSelected = !allSelected
        }
        tableView.reloadData()
        updateSelectAllButton()
        updateDownloadButton()
    }

    @objc func downloadButtonTapped() {
        let selectedFiles = fileList.filter { $0.isSelected }.map { $0.fileName }

        if selectedFiles.isEmpty {
            // 显示提示
            BDLogger.warning("请至少选择一个文件进行下载")
            return
        }

        downloadButtonCallback?(selectedFiles)
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    // MARK: - Private Methods

    private func updateSelectAllButton() {
        let allSelected = fileList.allSatisfy { $0.isSelected }
        selectAllButton.setTitle(allSelected ? "取消全选" : "全选", for: .normal)
    }

    private func updateDownloadButton() {
        let selectedCount = fileList.filter { $0.isSelected }.count
        downloadButton.setTitle("下载选中的文件 (\(selectedCount))", for: .normal)
        downloadButton.backgroundColor = selectedCount > 0 ? .blue.withAlphaComponent(0.8) : .gray.withAlphaComponent(0.5)
        downloadButton.isEnabled = selectedCount > 0
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension FileListDialog: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileListCell", for: indexPath) as! FileListCell
        let file = fileList[indexPath.row]
        cell.configure(with: file)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fileList[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateSelectAllButton()
        updateDownloadButton()
    }
}

// MARK: - 文件列表单元格

class FileListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(checkboxImageView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileInfoLabel)
        contentView.addSubview(fileSizeLabel)
    }

    private func setupConstraints() {
        checkboxImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(24)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(checkboxImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-15)
        }

        fileInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(5)
            make.left.equalTo(fileNameLabel)
            make.right.equalTo(fileNameLabel)
        }

        fileSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(fileInfoLabel.snp.bottom).offset(5)
            make.left.equalTo(fileNameLabel)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    // MARK: - UI Components

    private lazy var checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .blue
        return imageView
    }()

    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    private lazy var fileInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    private lazy var fileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()

    // MARK: - Configuration

    func configure(with file: FileInfoModel) {
        checkboxImageView.image = UIImage(systemName: file.isSelected ? "checkmark.circle.fill" : "circle")
        fileNameLabel.text = file.fileName

        var infoText = ""
        if let date = file.fileDate {
            infoText += "日期: \(date)\n"
        }
        infoText += "类型: \(file.fileTypeDescription)"
        fileInfoLabel.text = infoText

        fileSizeLabel.text = "大小: \(file.fileSizeDescription)"
    }
}
