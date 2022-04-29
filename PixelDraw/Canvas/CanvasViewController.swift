//
//  ViewController.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/24.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import XHYCategories

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

    private let pixelSize: CGFloat = 15
    private var model: CanvasListModel

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

    private var willTerminate: NSObjectProtocol?

    init(model: CanvasListModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        willTerminate = nil
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

        willTerminate = NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            self?.saveData()
        }

        recoveryCanvas()
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
        setToolbarItems([item], animated: false)
    }

    private var isWillAppear = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        guard !isWillAppear else { return }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        isWillAppear = true
    }

    private var isDidAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setToolbarHidden(false, animated: true)
        guard !isDidAppear else { return }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        isDidAppear = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sHeight: CGFloat = scrollView.frame.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
        let sWidth: CGFloat = scrollView.frame.size.width
        let cHeight = canvas.frame.height
        let cWidth = canvas.frame.width

        let sScale: CGFloat = sWidth/sHeight
        let cScale: CGFloat = cWidth/cHeight
        if sHeight > cHeight, sWidth > cWidth {
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 5
            contentView.snp.remakeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
                make.width.equalToSuperview()
                make.width.equalTo(contentView.snp.height).multipliedBy(sScale)
            }
        } else {
            if sScale > cScale {
                let margin = (sWidth - sHeight*cScale)/2
                scrollView.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
                scrollView.minimumZoomScale = sHeight/cHeight
                scrollView.maximumZoomScale = sWidth/(10*15)
            } else {
                let margin = (sHeight - sWidth/cScale)/2
                scrollView.minimumZoomScale = sWidth/cWidth
                scrollView.maximumZoomScale = sHeight/(10*15/sScale)
                scrollView.contentInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)

            }
            contentView.snp.remakeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
                make.width.equalTo(contentView.snp.height).multipliedBy(cScale)
            }
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

    func recoveryCanvas() {
        for pixelState in model.drawPoints {
            canvas.colorChanged(newPixelState: pixelState)
        }
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
        let hud = ZLProgressHUD(style: .dark)
        hud.show()
        saveData { [weak self] in
            hud.hide()
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func saveData(finish: VoidHandler? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.model.snapshot = self.canvas.makeImageFromSelf()
            self.model.drawPoints = self.canvas.getAllPixel()
            self.model.lastDate = Date()
            DispatchQueue.main.async {
                HomeViewModel.shared.update(model: self.model)
                finish?()
            }
        }
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
