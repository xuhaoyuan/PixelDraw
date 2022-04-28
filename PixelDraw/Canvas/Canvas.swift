import UIKit
import Disk

class Canvas: UIView {
	class Pixel: CALayer { }

    var paintBrushColor = UIColor.black
    
    private let widthPixels: Int
    private let heightPixels: Int
    private let pixelSize: CGFloat
 	private var pixels: Array<Array<Pixel>> = []
    private let canvasDefaultColor: UIColor

    private(set) var viewModel: CanvasViewModel
    private var lastTouched = Set<Pixel>()

    init(canvasModel: CanvasListModel) {
        canvasDefaultColor = .clear
        self.widthPixels = canvasModel.widthPixels
        self.heightPixels = canvasModel.heightPixels
        self.pixelSize = canvasModel.pixelSize
        self.viewModel = CanvasViewModel(initialState: canvasModel.contextModel)
        let width: CGFloat = CGFloat(widthPixels) * pixelSize
        let height: CGFloat = CGFloat(heightPixels) * pixelSize
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
		viewModel.delegate = self
        snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
		setupView()
        viewModel.recoveryCanvas()
        backgroundColor = UIColor.white
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDrag(sender:)))
		tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
		let dragGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleDrag(sender:)))
        dragGestureRecognizer.delegate = self
		addGestureRecognizer(dragGestureRecognizer)
        isUserInteractionEnabled = true

		pixels = []
		for heightIndex in 0..<heightPixels {
			pixels.append([])
			for widthIndex in 0..<widthPixels {
                let pixel = createPixel(defaultColor: .clear)
				pixel.frame = CGRect(
					x: CGFloat(widthIndex) * pixelSize,
					y: CGFloat(heightIndex) * pixelSize,
					width: pixelSize,
					height: pixelSize
				)
				pixels[heightIndex].append(pixel)
                layer.addSublayer(pixel)
			}
		}
	}

	private func createPixel(defaultColor: UIColor) -> Pixel {
		let pixel = Pixel()
        pixel.backgroundColor = defaultColor.cgColor
		pixel.borderWidth = 0.5
		pixel.borderColor = UIColor.lightGray.cgColor
		return pixel
	}

	@objc private func handleDrag(sender: UIGestureRecognizer) {
		switch sender.state {
		case .began, .changed:
			draw(atPoint: sender.location(in: self))
		case .ended:
			draw(atPoint: sender.location(in: self))
			viewModel.endDrawing()
		default: break
		}
	}

	private func draw(atPoint point: CGPoint) {
		let y = Int(point.y / pixelSize)
		let x = Int(point.x / pixelSize)
		guard y < heightPixels && x < widthPixels && y >= 0 && x >= 0 else { return }
		viewModel.drawAt(x: x, y: y, color: paintBrushColor)
	}

	private func removeGrid() {
		for row in pixels {
			for pixel in row {
				pixel.borderWidth = 0
			}
		}
	}

	private func addGrid() {
		for row in pixels {
			for pixel in row {
				pixel.borderWidth = 0.5
			}
		}
	}

	func makeImageFromSelf() -> UIImage {
		removeGrid()
		UIGraphicsBeginImageContext(self.frame.size)
		layer.render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		addGrid()
		return image!
	}
}

extension Canvas: CanvasDelegate {
	func colorChanged(newPixelState pixelState: PixelState) {
        guard pixels.count > pixelState.y else { return }
        let rows = pixels[pixelState.y]
        guard rows.count > pixelState.x else { return }
        rows[pixelState.x].backgroundColor = pixelState.color.cgColor
	}

	func clearCanvas() {
		for row in pixels {
			for pixel in row {
                pixel.backgroundColor = canvasDefaultColor.cgColor
			}
		}
	}

    func getAllPixel() -> Set<PixelState> {
        var array: Set<PixelState> = []
        for (yIndex, row) in pixels.enumerated() {
            for (xIndex ,pixel) in row.enumerated() where pixel.backgroundColor != UIColor.clear.cgColor {
                array.insert(PixelState(x: xIndex, y: yIndex, color: UIColor(cgColor: pixel.backgroundColor ?? UIColor.white.cgColor)))
            }
        }
        return array
    }
}

extension Canvas: UIGestureRecognizerDelegate {

//	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view is UIScrollView) || (otherGestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer.view is UIScrollView) {
//            if gestureRecognizer is UITapGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer {
//                gestureRecognizer.state = .cancelled
//                return true
//            } else {
//                otherGestureRecognizer.state = .cancelled
//                return false
//            }
//        } else {
//            return true
//        }
//	}

}
