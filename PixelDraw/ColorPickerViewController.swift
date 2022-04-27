//
//  ColorPickerViewController.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/20.
//

import UIKit
import SnapKit
import RxSwift

class ColorPickerViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private let topView = UIView()

    private let dataView = ReportDataView()

    private let barPickerView = DivoomColorBarPickerView()
    private let squareView = DivoomColorSquareView()
    private let colorLumpView = ColorPickerView()

    private let contentView = UIView()

//    static func show(

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        makeUI()

        barPickerView.valueChangedBlock = { [weak self] value in
            self?.squareView.hvalue = value
        }

        squareView.colorChangedBlock = { [weak self] value in
            self?.topView.backgroundColor = value
            self?.dataView.update(color: value)
        }

        colorLumpView.colorHandler = { [weak self] value in
            self?.fillColor(color: value)
        }

        dataView.observable.bind { [weak self] color in
            guard let color = color else { return }
            self?.fillColor(color: color)
        }.disposed(by: disposeBag)

    }

    private func makeUI() {
        contentView.backgroundColor = UIColor.white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topView.border(color: UIColor.white, width: 3)

        contentView.addSubview(dataView)
        contentView.addSubview(topView)
        contentView.addSubview(barPickerView)
        contentView.addSubview(squareView)
        contentView.addSubview(colorLumpView)

        let margin = 8

        dataView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(margin)
            make.leading.equalTo(margin)
            make.trailing.equalTo(-margin)
        }

        topView.snp.makeConstraints { make in
            make.top.equalTo(dataView.snp.bottom).offset(margin)
            make.leading.equalTo(margin)
            make.trailing.equalTo(-margin)
            make.height.equalTo(64)
        }

        barPickerView.snp.makeConstraints { make in
            make.leading.equalTo(margin)
            make.trailing.equalTo(-margin)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(50)
        }

        colorLumpView.snp.makeConstraints { make in
            make.leading.equalTo(margin)
            make.trailing.equalTo(-margin)
            make.bottom.equalTo(barPickerView.snp.top).offset(-margin)
            make.height.equalTo(40)
        }

        squareView.snp.makeConstraints { make in
            make.leading.equalTo(margin)
            make.trailing.equalTo(-margin)
            make.top.equalTo(topView.snp.bottom).offset(margin)
            make.bottom.equalTo(colorLumpView.snp.top).offset(-margin)
        }
    }
    

    private func fillColor(color: UIColor) {
        guard var comp = color.cgColor.components else { return }
        if comp.count == 2 {
            comp.append(0)
        }

        let r = Float(comp[0])
        let g = Float(comp[1])
        let b = Float(comp[2])
        // let _ = Float(comp[3])
        var h: Float = 0
        var s: Float = 0
        var v: Float = 0
        RGBToHSV(r, g, b, &h, &s, &v, true)
        barPickerView.hvalue = CGFloat(h)
        squareView.hvalue = CGFloat(h)
        squareView.svvalue = CGPoint(x: CGFloat(s), y: CGFloat(v))
    }
}

