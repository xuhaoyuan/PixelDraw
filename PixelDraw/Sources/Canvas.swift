import UIKit
import Disk

public class Canvas: UIView {
	class Pixel: CALayer {
	}

	var pixels: Array<Array<Pixel>>!
	let width: Int
	let height: Int
	let pixelSize: CGFloat
	let canvasDefaultColor: UIColor
	public var paintBrushColor = UIColor.black
	var viewModel: CanvasViewModel
	var lastTouched = Set<Pixel>()

	public init(width: Int, height: Int, pixelSize: CGFloat, canvasColor: UIColor) {
		self.width = width
		self.height = height
		self.pixelSize = pixelSize
		canvasDefaultColor = canvasColor
        let model = try? Disk.retrieve("/pixelData/data", from: .documents, as: CanvasModel.self)
		viewModel = CanvasViewModel(initialState: model)
        let width: CGFloat = CGFloat(width) * pixelSize
        let height: CGFloat = CGFloat(height) * pixelSize
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
		viewModel.delegate = self
        snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
		setupView()
        viewModel.recoveryCanvas()
        backgroundColor = canvasColor
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
		for heightIndex in 0..<height {
			pixels.append([])
			for widthIndex in 0..<width {
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
		guard y < height && x < width && y >= 0 && x >= 0 else { return }
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

	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view is UIScrollView && otherGestureRecognizer.numberOfTouches == 2) || (otherGestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer.view is UIScrollView) {
            otherGestureRecognizer.state = .cancelled
            print("false")
            return false
        } else {

            print(gestureRecognizer, "---", otherGestureRecognizer)
            return true
        }
	}

}
