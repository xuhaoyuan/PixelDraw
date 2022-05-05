//
//  DivoomColorBarPickerView.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/5/5.
//

import UIKit
import XHYCategories

class DivoomColorBarPickerView: UIView {

    private(set) var hvalue: CGFloat = 0
    var valueChangedBlock: SingleHandler<CGFloat>?
    var colorChangedBlock: SingleHandler<UIColor>?

    private var indicator: ColorIndicatorView = ColorIndicatorView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        var hsv: [Float] = [0.0,1.0,1.0]
        let numberPointer = UnsafeMutablePointer<Float>.allocate(capacity: 3)
        numberPointer.initialize(from: &hsv, count: 3)
        let imageRef: CGImage = createHSVBarContentImage(InfComponentIndexHue, numberPointer).takeUnretainedValue()
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.draw(imageRef, in: rect)

        let x = hvalue * frame.width
        indicator.center = CGPoint(x: x, y: bounds.midY)
    }

    func setHvalue(_ value: CGFloat) {
        hvalue = max(0, min(value, 1))
        let x = hvalue * frame.width
        indicator.center = CGPoint(x: x, y: bounds.midY)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        indcatorViewWithTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        indcatorViewWithTouch(touch)
    }

    private func indcatorViewWithTouch(_ touch: UITouch) {
        let p = touch.location(in: self)
        if p.x > 0 && p.x <= self.bounds.width {
            indicator.center = CGPoint(x: p.x, y: self.indicator.center.y)
            setHvalue(indicator.center.x / self.bounds.width)
            colorChangedBlock?(UIColor(hue: hvalue, saturation: 1, brightness: 1, alpha: 1) )
            valueChangedBlock?(hvalue)
        }
    }
}
