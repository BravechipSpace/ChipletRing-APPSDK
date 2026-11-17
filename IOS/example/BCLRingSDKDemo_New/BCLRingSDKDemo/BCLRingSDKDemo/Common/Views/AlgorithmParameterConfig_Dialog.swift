import BCLRingSDK
import QMUIKit
import SnapKit
import UIKit

/// 算法参数设置弹窗，使用与其他配置弹窗一致的QMUI容器和按钮样式。
final class AlgorithmParameterConfig_Dialog: UIView {
    /// 校验成功后返回完整配置；取消不触发回调。
    var confirmButtonCallback: ((BCLAlgorithmParameterConfig) -> Void)?
    private let fields = (0..<4).map { _ in QMUITextField() }
    private let ranges = [0...23, 0...23, 2...20, 20...240]
    private let names = ["长睡开始小时", "长睡结束小时", "计步初始阈值", "PPG周期测量时长"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        layer.cornerRadius = 15
        clipsToBounds = true
        let title = UILabel()
        title.text = "算法参数配置"
        title.font = .boldSystemFont(ofSize: 18)
        addSubview(title)
        title.snp.makeConstraints { $0.top.equalToSuperview().offset(20); $0.centerX.equalToSuperview() }
        let cancel = makeButton("取消", color: .gray.withAlphaComponent(0.5), action: #selector(cancelTapped))
        let confirm = makeButton("确认设置", color: .blue.withAlphaComponent(0.8), action: #selector(confirmTapped))
        let buttons = UIStackView(arrangedSubviews: [cancel, confirm])
        buttons.spacing = 20
        buttons.distribution = .fillEqually
        addSubview(buttons)
        buttons.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        addSubview(scroll)
        scroll.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(buttons.snp.top).offset(-16)
        }
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        scroll.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(scroll).offset(-40)
        }
        let defaults = ["22", "8", "5", "60"]
        for index in fields.indices {
            let label = UILabel()
            let unit = index < 2 ? "小时" : "秒"
            label.text = "\(names[index])（\(ranges[index].lowerBound)...\(ranges[index].upperBound)\(unit)）"
            label.font = .systemFont(ofSize: 14)
            label.numberOfLines = 0
            stack.addArrangedSubview(label)
            let field = fields[index]
            field.text = defaults[index]
            field.keyboardType = .numberPad
            field.backgroundColor = .gray.withAlphaComponent(0.1)
            field.layer.cornerRadius = 8
            field.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            stack.addArrangedSubview(field)
            field.snp.makeConstraints { $0.height.equalTo(40) }
        }
        let note = UILabel()
        note.text = "以上为示例值，并非设备当前配置。长睡时间允许跨越零点。"
        note.font = .systemFont(ofSize: 12)
        note.textColor = .darkGray
        note.numberOfLines = 0
        stack.addArrangedSubview(note)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 逐字段校验，避免UInt8转换截断或非法输入导致崩溃。
    @objc private func confirmTapped() {
        var values: [UInt8] = []
        for index in fields.indices {
            let text = fields[index].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard let value = Int(text), ranges[index].contains(value) else {
                if let window = window {
                    QMUITips.showError("\(names[index])请输入\(ranges[index].lowerBound)...\(ranges[index].upperBound)的整数", in: window)
                }
                return
            }
            values.append(UInt8(value))
        }
        endEditing(true)
        confirmButtonCallback?(BCLAlgorithmParameterConfig(
            longSleepStartHour: values[0], longSleepEndHour: values[1],
            stepCountInitialThresholdSeconds: values[2], ppgPeriodicMeasurementDurationSeconds: values[3]))
        cancelTapped()
    }

    @objc private func cancelTapped() {
        QMUIModalPresentationViewController.hideAllVisibleModalPresentationViewControllerIfCan()
    }

    private func makeButton(_ title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 22
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
