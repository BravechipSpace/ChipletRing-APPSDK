//
//  FunctionDemoCell.swift
//  BCLRingSDKDemo
//
//  Created by JianDan on 2025/11/20.
//

import UIKit
import SnapKit

class FunctionDemoCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "FunctionDemoCell"

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var requiresConnectionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "link.circle.fill")
        imageView.tintColor = UIColor.systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(requiresConnectionIcon)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        requiresConnectionIcon.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(6)
            make.size.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Configuration

    func configure(with model: FunctionDemoModel) {
        titleLabel.text = model.title
        requiresConnectionIcon.isHidden = !model.requiresConnection

        // 设置选中状态的背景色
        containerView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : UIColor.systemBackground
    }

    // MARK: - Highlighted State

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.alpha = self.isHighlighted ? 0.6 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : UIColor.systemBackground
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
        }
    }
}
