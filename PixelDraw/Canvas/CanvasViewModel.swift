import UIKit
import Disk

protocol CanvasDelegate: AnyObject {
    func colorChanged(newPixelState pixelState: PixelState)
    func clearCanvas()
    func getAllPixel() -> Set<PixelState>
}

public struct CanvasState: Codable, Equatable {
    let state: Set<PixelState>
}

public struct PixelState: Hashable, Codable {
    let x: Int
    let y: Int
    let color: UIColor

    init(x: Int, y: Int, color: UIColor) {
        self.x = x
        self.y = y
        self.color = color
    }

    enum CodingKeys: CodingKey {
        case x
        case y
        case color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try container.decode(Int.self, forKey: .x)
        self.y = try container.decode(Int.self, forKey: .y)
        let hex = try container.decode(String.self, forKey: .color)
        color = UIColor(hexString: hex) ?? UIColor.black
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        let hexColor = self.color.hex
        try container.encode(hexColor, forKey: .color)
    }


    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(color)
    }

    public static func ==(lhs: PixelState, rhs: PixelState) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.color == rhs.color
    }
}

struct CanvasModel: Codable, Equatable {
    var stateHistory: Array<CanvasState>
    var currentDraw: Set<PixelState>
    var undoneChanges: Array<CanvasState>

    init(stateHistory: Array<CanvasState> = [],
         currentDraw: Set<PixelState> = [],
         undoneChanges: Array<CanvasState> = []) {
        self.stateHistory = stateHistory
        self.currentDraw = currentDraw
        self.undoneChanges = undoneChanges
    }
}

class CanvasViewModel: NSObject {

    private var model = CanvasModel()

    weak var delegate: CanvasDelegate?

    init(initialState: CanvasModel? = nil) {
        if let initialState = initialState {
            self.model = initialState
        }
        super.init()
    }
    
    func drawAt(x: Int, y: Int, color: UIColor) {
        let pixelState = PixelState(x: x, y: y, color: color)
        let (inserted, _) = model.currentDraw.insert(pixelState)
        if inserted {
            model.undoneChanges = []
            delegate?.colorChanged(newPixelState: pixelState)
        }
    }

    func endDrawing() {
        model.stateHistory.append(CanvasState(state: model.currentDraw))
        model.currentDraw = []
    }

    struct Point: Hashable {
        let x: Int
        let y: Int


        func hash(into hasher: inout Hasher) {
            hasher.combine(x)
            hasher.combine(y)
        }

        public static func ==(lhs: Point, rhs: Point) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }

    func clear() {
        delegate?.clearCanvas()
        model = CanvasModel()
    }

    func undo() {
        guard let lastDraw = model.stateHistory.popLast() else { return }

        delegate?.clearCanvas()
        for state in model.stateHistory {
            apply(canvasState: state)
        }
        model.undoneChanges.append(lastDraw)
    }

    func redo() {
        guard let lastUndoneDraw = model.undoneChanges.popLast() else { return }
        apply(canvasState: lastUndoneDraw)
        model.stateHistory.append(lastUndoneDraw)
    }

    func apply(canvasState: CanvasState) {
        for pixelState in canvasState.state {
            delegate?.colorChanged(newPixelState: pixelState)
        }
    }
}

