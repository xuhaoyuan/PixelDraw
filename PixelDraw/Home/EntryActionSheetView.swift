//
//  EntryActionSheetView.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/28.
//

import UIKit
import XHYCategories
import SwiftEntryKit

class EntryActionSheetView: UIView {

    static func show(handler: @escaping (CanvasSize) -> Void) {
        let view = EntryActionSheetView(sizeHandler: handler)
        SwiftEntryKit.display(entry: view, using: .bottom)
    }

    private let titleLabel: UILabel = UILabel(text: "请选择画布大小", font: UIFont.systemFont(ofSize: 16, weight: .bold), color: .black, alignment: .center)
    private let cancelBtn: UIButton = UIButton(title: "取消", titleColor: .black, font: .systemFont(ofSize: 14, weight: .regular))
    private let confirmBtn: UIButton = UIButton(title: "确认", titleColor: .black, font: .systemFont(ofSize: 14, weight: .regular))
    private let pickView = UIPickerView()

    private let items: [Int] = {
        var tmp: [Int] = []
        for i in 1...20 {
            tmp.append(i*10)
        }
        return tmp
    }()

    init(sizeHandler: @escaping (CanvasSize) -> Void) {
        super.init(frame: .zero)
        pickView.delegate = self
        pickView.dataSource = self

        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray

        addSubview(titleLabel)
        addSubview(cancelBtn)
        addSubview(confirmBtn)
        addSubview(pickView)
        addSubview(lineView)

        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(38)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        cancelBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(16)
        }

        confirmBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(-16)
        }

        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(0.5)
        }

        pickView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-36)
        }

        cancelBtn.addTapHandler {
            SwiftEntryKit.dismiss()
        }

        confirmBtn.addTapHandler { [weak self] in
            guard let self = self else { return }
            let width = self.items[self.pickView.selectedRow(inComponent: Component.width.rawValue)]
            let height = self.items[self.pickView.selectedRow(inComponent: Component.height.rawValue)]
            SwiftEntryKit.dismiss {
                sizeHandler(CanvasSize(w: width, h: height))
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EntryActionSheetView: UIPickerViewDelegate, UIPickerViewDataSource {

    enum Component: Int, CaseIterable {
        case width
        case height
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Component.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(items[row])"
    }
}

extension EKAttributes {
    static var bottom: EKAttributes {
        var attr = EKAttributes()
        attr.statusBar = .light
        attr.position = .bottom
        attr.displayDuration = .infinity
        attr.positionConstraints.size = .init(width: .fill, height: .intrinsic)
        attr.screenBackground = .color(color: EKColor(#colorLiteral(red: 0.1098039216, green: 0.1254901961, blue: 0.1725490196, alpha: 0.8)))
        attr.positionConstraints.safeArea = .overridden
        attr.entryInteraction = .absorbTouches
        attr.roundCorners = .top(radius: 20)
        attr.scroll = .disabled
        attr.screenInteraction = .absorbTouches
        attr.entryBackground = .color(color: .white)
        attr.entranceAnimation = EKAttributes.Animation(translate: EKAttributes.Animation.Translate(duration: 0.4, anchorPosition: .bottom, delay: 0, spring: .init(damping: 0.8, initialVelocity: 0)))
        return attr
    }
}
