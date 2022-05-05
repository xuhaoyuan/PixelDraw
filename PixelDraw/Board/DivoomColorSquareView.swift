//
//  DivoomColorSquareView.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/5/5.
//

import UIKit
import XHYCategories

class DivoomColorSquareView: UIView {

    func setHvalue(_ value: CGFloat) {
        hvalue = max(0, min(value, 1))
        updateContent()
        setNeedsLayout()
    }

    private(set) var hvalue: CGFloat = 0

    func setvvalue(_ value: CGPoint) {
        guard svvalue != value else { return }
        svvalue = value
        setNeedsLayout()
    }

    private(set) var svvalue: CGPoint = .zero
    private(set) var curColor: UIColor = .white

    var colorChangedBlock: SingleHandler<UIColor>?

    private var indicator: ColorIndicatorView = ColorIndicatorView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(indicator)
        setHvalue(0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let x = svvalue.x * bounds.width
        let y = bounds.height - svvalue.y*bounds.height
        indicator.center = CGPoint(x: x, y: y)

        curColor = UIColor(hue: hvalue, saturation: svvalue.x, brightness: svvalue.y, alpha: 1)
        colorChangedBlock?(curColor)
    }

    private func updateContent() {
        let image = createSaturationBrightnessSquareContentImageWithHue(Float(self.hvalue) * 360).takeUnretainedValue()
        layer.contents = image
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        indcatorViewWithTouch(touch: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        indcatorViewWithTouch(touch: touch)
    }

    private func indcatorViewWithTouch(touch: UITouch) {
        var p = touch.location(in: self)
        let w = bounds.width
        let h = bounds.height

        if p.x < 0 {
            p.x = 0
        }
        if p.x > w {
            p.x = w
        }
        if p.y < 0 {
            p.y = 0
        }
        if p.y > h {
            p.y = h
        }
        setvvalue(CGPoint(x: p.x/w, y: 1.0 - p.y / h))
        setNeedsLayout()
    }

}
