//
//  ViewController.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/24.
//

import UIKit
import SnapKit
import ZLPhotoBrowser

class CanvasViewController: UIViewController {

    static func show(model: CanvasListModel, from: UIViewController) {
        let vc = CanvasViewController(model: model)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        from.showDetailViewController(nav, sender: nil)
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.delegate = self
        return scrollView
    }()

    private let contentView: UIView = UIView()

    private lazy var canvas: Canvas = Canvas(canvasModel: model)
    private let colorPicker = ColorPickerView(entry: .draw)

    private let heightWidthInPixels: Int = 50
    private let pixelSize: CGFloat = 15
    private let model: CanvasListModel

    private lazy var undoBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "undo"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(undoButtonPressed))
        return item
    }()

    private lazy var redoBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "redo"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(redoButtonPressed))
        return item
    }()

    private lazy var downloadBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "download"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonPressed))
        return item
    }()

    private lazy var clearBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "clear"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(clearButtonPressed))
        return item
    }()

    private lazy var closeBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "close"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(closeButtonPressed))
        return item
    }()

    init(model: CanvasListModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()

        colorPicker.colorHandler = { [weak self] color in
            self?.canvas.paintBrushColor = color
        }
        colorPicker.addHandler = { [weak self] in
            guard let self = self else { return }
            ColorListViewController.show(from: self)
        }
    }

    private func makeUI() {
        view.backgroundColor = UIColor.black
        view.addSubview(scrollView)

        navigationItem.leftBarButtonItems = [closeBarItem, clearBarItem]
        navigationItem.rightBarButtonItems = [downloadBarItem, redoBarItem, undoBarItem]

        scrollView.addSubview(contentView)
        contentView.addSubview(canvas)

        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.height.equalToSuperview().priority(.low)
        }

        canvas.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        let item = UIBarButtonItem(customView: colorPicker)
        navigationController?.setToolbarHidden(false, animated: true)
        setToolbarItems([item], animated: false)
    }

    private var isWillAppear = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isWillAppear else { return }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        isWillAppear = true
    }
    private var isDidAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isDidAppear else { return }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        isDidAppear = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let adjustedHeight: CGFloat = scrollView.frame.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
        let scrollWidth: CGFloat = scrollView.frame.size.width
        let cLength = max(canvas.frame.width, canvas.frame.height)
        let vlength = min(scrollWidth, adjustedHeight)
        if cLength > vlength {
            scrollView.minimumZoomScale = vlength/cLength
            scrollView.maximumZoomScale = vlength/cLength*5
        } else {
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 2
        }

        contentView.snp.remakeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(contentView.snp.height).multipliedBy(scrollWidth/adjustedHeight)
        }
    }

    @objc private func undoButtonPressed() {
        canvas.viewModel.undo()
    }

    @objc private func redoButtonPressed() {
        canvas.viewModel.redo()
    }

    @objc private func saveButtonPressed() {
        let image = canvas.makeImageFromSelf()
        ZLEditImageViewController.showEditImageVC(parentVC: self, animate: true, image: image, editModel: nil) { img, _ in
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
    }

    @objc private func zoomButtonPressed() {
        //        delegate?.zoomPressed()
    }

    @objc private func clearButtonPressed() {
        let vc = UIAlertController(title: "hi", message: "要清空画布吗？", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.canvas.viewModel.clear()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        vc.addAction(confirm)
        vc.addAction(cancel)
        present(vc, animated: true, completion: nil)
    }

    @objc private func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension CanvasViewController: UIScrollViewDelegate {


    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentView.transform = CGAffineTransform.init(scaleX: scrollView.zoomScale, y: scrollView.zoomScale)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

}
