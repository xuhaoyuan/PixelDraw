import UIKit

protocol CanvasControlCenterDelegate: AnyObject {
    func undoPressed()
    func redoPressed()
    func savePressed()
    func zoomPressed()
    func clearPressed()
}

class CanvasControlCenter: UIView {
    let theme: Theme
    weak var delegate: CanvasControlCenterDelegate?

    init(theme: Theme) {
        self.theme = theme
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = UIColor.black

        let undoButton = UIButton()
        undoButton.setImage(UIImage(named: "undo"), for: .normal)
        undoButton.addTarget(self, action: #selector(undoButtonPressed), for: .touchUpInside)

        let redoButton = UIButton()
        redoButton.setImage(UIImage(named: "redo"), for: .normal)
        redoButton.addTarget(self, action: #selector(redoButtonPressed), for: .touchUpInside)

        let zoomButton = UIButton()
        zoomButton.setImage(UIImage(named: "collect"), for: .normal)
        zoomButton.addTarget(self, action: #selector(zoomButtonPressed), for: .touchUpInside)

        let saveButton = UIButton()
        saveButton.setImage(UIImage(named: "download"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)


        let clearButton = UIButton()
        clearButton.setImage(UIImage(named: "clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)


        let lview = UIView()
        let rview = UIView()

        let stackView = UIStackView(subviews: [clearButton, lview, undoButton, zoomButton, redoButton, rview, saveButton], axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 8)
        addSubview(stackView)

        undoButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        redoButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        saveButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        zoomButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        lview.snp.makeConstraints { make in
            make.width.equalTo(rview)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    @objc func undoButtonPressed() {
        delegate?.undoPressed()
    }
    
    @objc func redoButtonPressed() {
        delegate?.redoPressed()
    }

    @objc func saveButtonPressed() {
        delegate?.savePressed()
    }

    @objc func zoomButtonPressed() {
        delegate?.zoomPressed()
    }


    @objc func clearButtonPressed() {
        delegate?.clearPressed()
    }
}
