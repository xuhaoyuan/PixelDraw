import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.registerCell(HomeCollectionCell.self)
        collectionView.registerCell(NewCanvasCollectionCell.self)
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

    private let disposeBag = DisposeBag()

    private enum Items: Equatable {
        case item(CanvasListModel)
        case new
    }

    private var canvasList: [Items] = [.new]

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()

        HomeViewModel.shared.obserable.bind { [weak self] list in
            self?.canvasList = list.map({ Items.item($0) }) + [.new]
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
    }

    private func makeUI() {
        title = "像素画板"
        view.backgroundColor = UIColor.white

        view.addSubview(deleteView)
        deleteView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(ges:)))
        collectionView.addGestureRecognizer(longPressGes)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = .black
    }

    private var moveIndexPath: IndexPath?
    @objc func handleLongGesture(ges: UILongPressGestureRecognizer) {
        var location = ges.location(in: collectionView)
        switch (ges.state) {
        case .began:
            moveIndexPath = nil
            guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
            moveIndexPath = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) {
                view.bringSubviewToFront(cell)
            }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            showDeleteView(true)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
            location = view.convert(location, from: collectionView)
            interactive(fromPoint: location)
        case .ended:
            location = view.convert(location, from: collectionView)
            guard deleteView.frame.contains(location), let indexPath = self.moveIndexPath else {
                showDeleteView(false)
                collectionView.endInteractiveMovement()
                return
            }
            collectionView.cancelInteractiveMovement()
            canvasList.remove(at: indexPath.row)
            collectionView.performBatchUpdates { [weak self] in
                self?.collectionView.deleteItems(at: [indexPath])
            } completion: { [weak self] _ in
                HomeViewModel.shared.remove(index: indexPath.row)
                self?.showDeleteView(false)
            }
        default:
            collectionView.cancelInteractiveMovement()
            interactive(fromPoint: .zero)
        }
    }

    private func showDeleteView(_ isShow: Bool) {
        if isShow {
            deleteView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(view.snp.bottom)
            }
        } else {
            deleteView.transform = CGAffineTransform.identity
            deleteView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .beginFromCurrentState]) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: { _ in

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
}


extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch canvasList[indexPath.row] {
        case .item(let canvas):
            CanvasViewController.show(model: canvas, from: self)
        case .new:
            EntryActionSheetView.show { size in
                let canvas = CanvasListModel(size: size)
                CanvasViewController.show(model: canvas, from: self)
                HomeViewModel.shared.append(model: canvas)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvasList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch canvasList[indexPath.row] {
        case .item(let canvas):
            let cell: HomeCollectionCell = collectionView.dequeueReusableCell(indexPath)
            cell.config(model: canvas)
            return cell
        case .new:
            let cell: NewCanvasCollectionCell = collectionView.dequeueReusableCell(indexPath)
            return cell
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - 16)/2
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        switch canvasList[indexPath.row] {
        case .item: return true
        case .new: return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let color = canvasList[sourceIndexPath.row]
        canvasList.removeAll { $0 == color }
        canvasList.insert(color, at: destinationIndexPath.row)
        HomeViewModel.shared.update(list: canvasList.compactMap({
            switch $0 {
            case .item(let value):
                return value
            case .new:
                return nil
            }
        }))
    }
}
