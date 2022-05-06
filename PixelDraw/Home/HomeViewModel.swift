import UIKit
import Disk
import RxSwift
import RxCocoa

struct CanvasSize: Codable, Equatable {
    let width: Int
    let height: Int

    init(w: Int, h: Int) {
        self.width = w
        self.height = h
    }
}

struct CanvasListModel: Codable, Equatable {
    let uuid: String
    var lastDate: Date
    let size: CanvasSize
    var drawPoints: Set<PixelState>
    private var snapshotData: Data?

    var snapshot: UIImage? {
        get {
            guard let data = snapshotData else { return nil }
            return UIImage(data: data)
        }
        set {
            snapshotData = newValue?.pngData()
        }
    }

    init(uuid: String = UUID().uuidString, size: CanvasSize, date: Date = Date(), drawPoints: Set<PixelState> = []) {
        self.uuid = uuid
        self.size = size
        self.lastDate = date
        self.drawPoints = drawPoints
    }
}

class HomeViewModel: NSObject {


    static let shared = HomeViewModel()

    var obserable: Observable<[CanvasListModel]> {
        return relay.distinctUntilChanged().asObservable()
    }

    private var relay: BehaviorRelay<[CanvasListModel]> = BehaviorRelay(value: [])

    private static let path = "/canvasList/data"
    private let disposbag = DisposeBag()

    override init() {
        super.init()

        do {
            let result = try Disk.retrieve(Self.path, from: .documents, as: [CanvasListModel].self)
            relay.accept(result)
        } catch {
            relay.accept([])
        }
    }

    func update(list: [CanvasListModel]) {
//        var list = relay.value
        relay.accept(list)
        saveData()
    }

    func update(model: CanvasListModel) {
        var list = relay.value
        list = list.map {
            $0.uuid == model.uuid ? model : $0
        }
        relay.accept(list)
        saveData()
    }

    func append(model: CanvasListModel) {
        var list = relay.value
        list.append(model)
        relay.accept(list)
        saveData()
    }

    func remove(index: Int) {
        var list = relay.value
        list.remove(at: index)
        relay.accept(list)
        saveData()
    }

    func saveData() {
        let list = relay.value
        do {
             try Disk.save(list, to: .documents, as: Self.path)
        } catch {

        }
    }
}
