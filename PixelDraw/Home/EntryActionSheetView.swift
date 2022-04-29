//
//  EntryActionSheetView.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/28.
//

import UIKit

class EntryActionSheetView: UIView {


    private let pickView = UIPickerView()

    private let items: [Int] = {
        var tmp: [Int] = []
        for i in 1...50 {
            tmp.append(i*10)
        }
        return tmp
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        pickView.delegate = self
        pickView.dataSource = self

        addSubview(pickView)
        pickView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
}
