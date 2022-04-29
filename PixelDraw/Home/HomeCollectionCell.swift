//
//  HomeCollectionCell.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/28.
//

import UIKit

class BaseHomeCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.2
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeCollectionCell: BaseHomeCell {

    private let dateLabel = UILabel(font: UIFont.systemFont(ofSize: 12, weight: .regular), color: .black, alignment: .left)
    private let sizeLabel = UILabel(font: UIFont.systemFont(ofSize: 12, weight: .regular), color: .black, alignment: .left)

    private let preImgView = UIImageView()

    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    func config(model: CanvasListModel) {
        dateLabel.text = model.lastDate.toString1
        sizeLabel.text = "\(model.size.width) X \(model.size.height)"
        preImgView.image = model.snapshot
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white

        blur.corner = 16
        blur.masksToBounds = true
        blur.contentMode = .scaleAspectFill
        preImgView.contentMode = .scaleAspectFit
        preImgView.backgroundColor = UIColor.white

        contentView.addSubview(blur)

        blur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let stackView = UIStackView(subviews: [sizeLabel, dateLabel], axis: .vertical, alignment: .leading, distribution: .fill, spacing: 8)
        sizeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        blur.contentView.addSubview(stackView)
        blur.contentView.addSubview(preImgView)

        preImgView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(8)
            make.bottom.equalTo(-8)
            make.top.equalTo(preImgView.snp.bottom).offset(6)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewCanvasCollectionCell: BaseHomeCell {

    private var imageView = UIImageView(image: UIImage(named: "homeAdd"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentView.addSubview(imageView)
        imageView.contentMode = .center
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
