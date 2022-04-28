//
//  ColorPickerView.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/21.
//

import UIKit
import RxSwift
import XHYCategories

class ColorPickerView: UIView {

    var colorHandler: SingleHandler<UIColor>?
    var addHandler: VoidHandler?

    private var list: [UIColor] = []
    private let disposbag = DisposeBag()

    enum Entry {
        case draw
        case color
    }
    private let entry: Entry
    init(entry: Entry) {
        self.entry = entry
        super.init(frame: .zero)

        switch entry {
        case .draw:
            backgroundColor = UIColor.clear
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = false
            collectionView.backgroundColor = UIColor.clear
        case .color:
            backgroundColor = UIColor.white
            collectionView.backgroundColor = UIColor.white
        }

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }

        self.setContentCompressionResistancePriority(.required, for: .vertical)

        ColorsViewModel.shared.colorsObservable.bind { [weak self] colors in
            self?.list = colors
            self?.collectionView.reloadData()
        }.disposed(by: disposbag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.registerCell(ColorCollectionCell.self)
        collectionView.registerCell(AddCollectionCell.self)
        return collectionView
    }()
}

extension ColorPickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum Section: Int, CaseIterable {
        case item
        case add
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .item:
            return list.count
        case .add:
            switch entry {
            case .draw:
                return 1
            case .color:
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .item:
            let cell: ColorCollectionCell = collectionView.dequeueReusableCell(indexPath)
            cell.backgroundColor = list[indexPath.row]
            cell.border(color: .gray, width: 2)
            return cell
        case .add:
            let cell: AddCollectionCell = collectionView.dequeueReusableCell(indexPath)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .item:
            colorHandler?(list[indexPath.row])
        case .add:
            addHandler?()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch entry {
        case .draw:
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        case .color:
            return CGSize(width: 40, height: 40)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = Section(rawValue: section) else { return .zero }
        switch section {
        case .item:
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        case .add:
            return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    }
}

class AddCollectionCell: UICollectionViewCell {

    private let img = UIImageView(image: UIImage(named: "add"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(img)
        img.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ColorCollectionCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            if isSelected {
                border(color: .white, width: 2)
            } else {
                border(color: .gray, width: 2)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        corner = frame.height/2
    }

}
