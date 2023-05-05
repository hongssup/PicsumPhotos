//
//  ImageListViewController.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ImageListViewController: UIViewController {
    
    private lazy var imageListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2.4
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let disposeBag = DisposeBag()
    let imageViewModel = ImageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        
        bindCollectionView()
        imageViewModel.fetchImages()
    }
    
    private func setupView() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        title = "ImageList"
    }
    
    private func setupCollectionView() {
        view.addSubview(imageListCollectionView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        imageListCollectionView.snp.makeConstraints {
            $0.edges.equalTo(safeArea)
        }
    }
}

extension ImageListViewController {
    func bindCollectionView() {
        imageViewModel.imageList.asObservable()
            .bind(to: imageListCollectionView.rx
                .items(cellIdentifier: "cell", cellType: ImageCollectionViewCell.self))
        { index, element, cell in
            cell.bind(model: element)
        }.disposed(by: disposeBag)
        
        imageListCollectionView.rx.modelSelected(Image.self).subscribe { model in
            let vc = DetailImageViewController()
            vc.imageInfo = model
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        imageListCollectionView.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.imageListCollectionView.contentOffset.y
            let contentHeight = self.imageListCollectionView.contentSize.height
            
            if contentHeight == 0 { return }
            
            if offSetY > (contentHeight - self.imageListCollectionView.frame.size.height - 100) {
                self.imageViewModel.fetchImages()
            }
        }.disposed(by: disposeBag)
    }
}

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 2
        return CGSize(width: width, height: width)
    }
}
