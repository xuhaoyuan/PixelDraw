//
//  ViewController.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/24.
//

import UIKit
import SnapKit
import ZLPhotoBrowser

class ViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.delegate = self
//        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        return scrollView
    }()

    private let contentView: UIView = UIView()

    private lazy var canvas: Canvas = Canvas(width: heightWidthInPixels, height: heightWidthInPixels, pixelSize: pixelSize, canvasColor: canvasDefaultColor)
    private let colorPicker = ColorPickerView(entry: .draw)
    private let control = CanvasControlCenter(theme: .light)

    private let heightWidthInPixels: Int = 50
    private let pixelSize: CGFloat = 15
    private let canvasDefaultColor: UIColor = UIColor.clear
    private let theme: Theme = .dark

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()

        control.delegate = self
        colorPicker.colorHandler = { [weak self] color in
            self?.canvas.paintBrushColor = color
        }
        colorPicker.addHandler = { [weak self] in
            guard let self = self else { return }
            ColorListViewController.show(from: self)
        }
    }

    private func makeUI() {

        view.addSubview(scrollView)
        view.addSubview(colorPicker)
        view.addSubview(control)
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        colorPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom).offset(16)
        }

        control.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
            make.top.equalTo(colorPicker.snp.bottom).offset(16)
        }
    }

    private var isDidAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isDidAppear else { return }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        isDidAppear = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cLength = max(canvas.frame.width, canvas.frame.height)
        let vlength = min(scrollView.frame.width, scrollView.frame.height)
        if cLength > vlength {
            scrollView.minimumZoomScale = vlength/cLength
            scrollView.maximumZoomScale = vlength/cLength*5
        } else {
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 2
        }

        contentView.snp.remakeConstraints { [weak self] make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.height.equalToSuperview().priority(.low)
            guard let self = self else { return }
            let size = self.scrollView.frame.size
            make.width.equalTo(contentView.snp.height).multipliedBy(size.width/size.height)
        }
    }
}

extension ViewController: UIScrollViewDelegate {


    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentView.transform = CGAffineTransform.init(scaleX: scrollView.zoomScale, y: scrollView.zoomScale)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

}


extension ViewController: CanvasControlCenterDelegate {

    func clearPressed() {
        let vc = UIAlertController(title: "hi", message: "要清空画布吗？", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.canvas.viewModel.clear()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        vc.addAction(confirm)
        vc.addAction(cancel)
        present(vc, animated: true, completion: nil)
    }
    
    func zoomPressed() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }

    func redoPressed() {
        canvas.viewModel.redo()
    }

    func undoPressed() {
        canvas.viewModel.undo()
    }

    func savePressed() {
        let image = canvas.makeImageFromSelf()
        ZLEditImageViewController.showEditImageVC(parentVC: self, animate: true, image: image, editModel: nil) { img, _ in
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
    }
}
