//
//  HomeViewModel.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/28.
//

import UIKit
import RxSwift
import RxCocoa

struct CanvasListModel: Codable, Equatable {
    let uuid: String
    let heightPixels: Int
    let widthPixels: Int
    let pixelSize: CGFloat
    var contextModel: CanvasModel
    private var snapshotData: Data?

    var snapshot: UIImage? {
        guard let data = snapshotData else { return nil }
        return UIImage(data: data)
    }

    static func defaultModel() -> Self {
        return CanvasListModel(heightPixels: 30, widthPixels: 30)
    }

    init(uuid: String = UUID().uuidString, heightPixels: Int, widthPixels: Int, pixelSize: CGFloat = 15, contextModel: CanvasModel = CanvasModel()) {
        self.uuid = uuid
        self.heightPixels = heightPixels
        self.widthPixels = widthPixels
        self.pixelSize = pixelSize
        self.contextModel = contextModel
    }
}

class HomeViewModel: NSObject {

    var relay: BehaviorRelay<[CanvasListModel]> = BehaviorRelay(value: [])

    private let disposbag = DisposeBag()

    override init() {
        super.init()
    }
}
