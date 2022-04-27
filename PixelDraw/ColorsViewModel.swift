//
//  ColorsViewModel.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/27.
//

import UIKit
import Disk
import RxSwift
import RxCocoa

class ColorsViewModel: NSObject {

    static let shared: ColorsViewModel = ColorsViewModel()

    var colorsObservable: Observable<[UIColor]> {
        return colorsRelay.distinctUntilChanged().asObservable()
    }

    private static let path = "/pixelData/colors"

    private let colorsRelay = BehaviorRelay<[UIColor]>(value: [])

    override init() {
        super.init()
        do {
            let hexColors: [String] = try Disk.retrieve(Self.path, from: .documents, as: [String].self)
            let colors: [UIColor] = hexColors.compactMap { UIColor(hex: $0) }
            colorsRelay.accept(colors)
        } catch {
            colorsRelay.accept(list)
        }

        colorsRelay.bind { [weak self] data in
            self?.saveData()
        }
    }

    func replace(color: UIColor, to newColor: UIColor) {
        var colors = colorsRelay.value
        colors = colors.map({ return $0 == color ? newColor : color })
    }

    func append(color: UIColor) {
        var colors = colorsRelay.value
        colors.append(color)
        colorsRelay.accept(colors)
    }

    func update(colors: [UIColor]) {
        colorsRelay.accept(colors)
    }

    private func saveData() {
        let colors = colorsRelay.value.map { $0.hex }
        do {
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(colors)
            try Disk.save(data, to: .documents, as: Self.path)
        } catch {

        }
    }

    private lazy var list: [UIColor] = {
        return [
            UIColor(r: 255, g: 255, b: 255, a: 1),
            UIColor(r: 0, g: 0, b: 0, a: 1),
            UIColor.red,
            UIColor.green,
            UIColor.blue,
            UIColor.cyan,
            UIColor.yellow,
            UIColor.magenta,
            UIColor.orange,
            UIColor.purple,
            UIColor.brown
        ]
    }()
}
