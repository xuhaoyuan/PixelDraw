//
//  ColorListViewController.swift
//  PixelDraw
//
//  Created by 许浩渊 on 2022/4/27.
//

import UIKit
import RxSwift
import RxCocoa

class ColorListViewController: UIViewController {

    static func show(from: UIViewController) {
        let vc = ColorListViewController()
        from.show(vc, sender: nil)
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.registerCell(ColorListCell.self)
        return collectionView
    }()

    private lazy var deleteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        let imageView = UIImageView(image: UIImage(named: "delete"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(38)
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        return view
    }()

    private var viewModel = ColorsViewModel.shared

    private let disposebag = DisposeBag()

    private var colors: [UIColor] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()

        viewModel.colorsObservable.bind { [weak self] colors in
            self?.colors = colors
            self?.collectionView.reloadData()
        }.disposed(by: disposebag)

        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(ges:)))
        collectionView.addGestureRecognizer(longPressGes)
    }

    private var moveIndexPath: IndexPath?
    @objc func handleLongGesture(ges: UILongPressGestureRecognizer) {
        let location = ges.location(in: collectionView)
        switch (ges.state) {
        case .began:
            moveIndexPath = nil
            guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
            moveIndexPath = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) {
                view.bringSubviewToFront(cell)
            }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
            interactive(fromPoint: location)
        case .ended:
            collectionView.endInteractiveMovement()
            interactive(fromPoint: .zero)
            guard deleteView.frame.contains(location) else { return }
            guard let indexPath = self.moveIndexPath else { return }
            colors.remove(at: indexPath.row)
            collectionView.performBatchUpdates { [weak self] in
                self?.collectionView.deleteItems(at: [indexPath])
            } completion: { [weak self] _ in
            }
        default:
            collectionView.cancelInteractiveMovement()
            interactive(fromPoint: .zero)
        }
    }

    private func interactive(fromPoint: CGPoint) {
        if deleteView.frame.contains(fromPoint) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) { [weak self] in
                self?.deleteView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in

            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) { [weak self] in
                self?.deleteView.transform = CGAffineTransform.identity
            } completion: { _ in

            }
        }
    }

    private func makeUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(deleteView)
        deleteView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ColorListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorListCell = collectionView.dequeueReusableCell(indexPath)
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - 16*4)/5
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let color = colors[sourceIndexPath.row]
        colors.removeAll { $0 == color }
        colors.insert(color, at: destinationIndexPath.row)
    }
}

fileprivate class ColorListCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        corner = frame.height/2
    }
}


