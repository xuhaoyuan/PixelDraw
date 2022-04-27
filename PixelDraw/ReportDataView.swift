//
//  ReportDataView.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/20.
//

import UIKit
import RxSwift
import RxCocoa
import XHYCategories

class ReportDataView: UIView {

    private let hexLabel = getLabel(text: "Hex:")
    private lazy var hexField = getField()

    private let rgbButton = UIButton(image: UIImage(named: "copy"), edge: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    private let hexButton = UIButton(image: UIImage(named: "copy"), edge: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))

    private let rLabel = getLabel(text: "R:")
    private lazy var rField = getField()

    private let gLabel = getLabel(text: "G:")
    private lazy var gField = getField()

    private let bLabel = getLabel(text: "B:")
    private lazy var bField = getField()

    private let disposeBag = DisposeBag()

    var observable: Observable<UIColor?> {
        return relay.distinctUntilChanged().asObservable()
    }

    private var relay = BehaviorRelay<UIColor?>(value: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)

        hexLabel.setContentHuggingPriority(.required, for: .horizontal)
        let topStackView = UIStackView(subviews: [hexLabel, hexField], axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 12)
        let bottomStackView = UIStackView(
            subviews: [getStack(label: rLabel, textField: rField),
                       getStack(label: gLabel, textField: gField),
                       getStack(label: bLabel, textField: bField)],
            axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 8)
        rgbButton.tintColor = UIColor.black
        hexButton.tintColor = UIColor.black
        addSubview(rgbButton)
        addSubview(hexButton)
        addSubview(topStackView)
        addSubview(bottomStackView)

        topStackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.equalTo(36)
        }
        bottomStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(36)
            make.top.equalTo(topStackView.snp.bottom).offset(8)
        }

        hexButton.setContentHuggingPriority(.required, for: .horizontal)
        hexButton.snp.makeConstraints { make in
            make.top.equalTo(topStackView)
            make.bottom.equalTo(topStackView)
            make.trailing.equalTo(-8)
            make.leading.equalTo(topStackView.snp.trailing).offset(8)
        }

        rgbButton.setContentHuggingPriority(.required, for: .horizontal)
        rgbButton.snp.makeConstraints { make in
            make.top.equalTo(bottomStackView)
            make.bottom.equalTo(bottomStackView)
            make.trailing.equalTo(-8)
            make.leading.equalTo(bottomStackView.snp.trailing).offset(8)
        }

        hexField.rx.controlEvent(.editingDidEnd).bind { [weak self] _ in
            guard let text = self?.hexField.text else { return }
            guard let color = UIColor(hexString: text) else { return }
            self?.relay.accept(color)
        }.disposed(by: disposeBag)

        rField.rx.controlEvent(.editingDidEnd).bind { [weak self] _ in
            self?.createColor()
        }.disposed(by: disposeBag)

        gField.rx.controlEvent(.editingDidEnd).bind { [weak self] _ in
            self?.createColor()
        }.disposed(by: disposeBag)

        bField.rx.controlEvent(.editingDidEnd).bind { [weak self] _ in
            self?.createColor()
        }.disposed(by: disposeBag)

        hexButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            guard let text = self.hexField.text else { return }
            UIPasteboard.general.string = text
        }.disposed(by: disposeBag)

        rgbButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            guard let r = self.rField.text,
                  let g = self.gField.text,
                  let b = self.bField.text else { return }
            UIPasteboard.general.string = "\(r) \(g) \(b)"
        }.disposed(by: disposeBag)
    }

    private func createColor() {
        guard let rStr = rField.text,
              let gStr = gField.text,
              let bStr = bField.text else { return }
        guard let r = Float(rStr), let g = Float(gStr), let b = Float(bStr) else { return }
        let color = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1)
        relay.accept(color)
    }

    func update(color: UIColor) {
        guard let comp = color.cgColor.components else { return }
        let r = Float(comp[0])
        let g = Float(comp[1])
        let b = Float(comp[2])
        rField.text = String(format: "%.2f", r*255)
        gField.text = String(format: "%.2f", g*255)
        bField.text = String(format: "%.2f", b*255)
        hexField.text = hexadecimalFromUIColor(color: color)
    }

    private func getStack(label: UILabel, textField: UITextField) -> UIStackView {
        let stack = UIStackView(subviews: [label, textField], axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 6)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func getLabel(text: String) -> UILabel {
        let font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        return UILabel(text: text,font: font, color: .black, alignment: .left)
    }

    private func getField() -> UITextField {
        let field = UITextField()
        field.textColor = UIColor.black
        field.keyboardType = .asciiCapableNumberPad
        field.returnKeyType = .done
        field.delegate = self
        field.inputAccessoryView = FinishInputView(callBack: {
            field.resignFirstResponder()
        })
        field.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        return field
    }


    func hexadecimalFromUIColor(color: UIColor) -> String? {
        guard color.cgColor.colorSpace?.model == .rgb else {
            if color == UIColor.clear {
                return "#000000FF"
            }
            return nil
        }

        guard let components = color.cgColor.components else { return nil }
        let r: CGFloat = components[0]
        let g: CGFloat = components[1]
        let b: CGFloat = components[2]
        let lr = lroundf(Float(r) * 255)
        let lg = lroundf(Float(g) * 255)
        let lb = lroundf(Float(b) * 255)

        if components.count < 4 {
            return String(format: "#%02lX%02lX%02lX", lr, lg, lb)
        } else {
            let a: CGFloat = components[3];
            let la = lroundf(Float(a) * 255)
            if a == 1 {
                return String(format: "#%02lX%02lX%02lX", lr, lg, lb)
            } else {
                return String(format: "#%02lX%02lX%02lX%02lX", lr, lg, lb, la)
            }
        }
    }
}

extension ReportDataView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {


        return true
    }
}


private class FinishInputView: UIView {

    private let confirmBtn = UIButton(title: "确认", titleColor: UIColor.white, font: .systemFont(ofSize: 18, weight: .bold), edge: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8), borderWidth: 2, borderColor: UIColor.white, cornerRadius: 32/2)

    init(callBack: @escaping VoidHandler) {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 38)
        super.init(frame: rect)
        addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
        confirmBtn.addTapHandler(callBack)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
