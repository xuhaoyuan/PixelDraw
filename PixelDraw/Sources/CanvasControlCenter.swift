import UIKit

protocol CanvasControlCenterDelegate: AnyObject {
    func undoPressed()
    func redoPressed()
    func savePressed()
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

        let saveButton = UIButton()
        saveButton.setImage(UIImage(named: "download"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)

        let stackView = UIStackView(subviews: [undoButton, redoButton, saveButton], axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 8)
        stackView.addArrangedSubview(undoButton)
        stackView.addArrangedSubview(redoButton)
        stackView.addArrangedSubview(saveButton)
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

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalToSuperview()
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
}
