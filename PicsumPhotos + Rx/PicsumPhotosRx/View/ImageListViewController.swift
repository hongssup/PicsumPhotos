//
//  ImageListViewController.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import UIKit
import SnapKit

final class ImageListViewController: UIViewController {
    
    private lazy var imageListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2.4
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var images: [Image] = [] {
        didSet {
            imageListCollectionView.reloadItems(at: imageListCollectionView.indexPathsForVisibleItems)
        }
    }
    
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        fetchImages()
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
    
    private func fetchImages() {
        Task {
            do {
                let query = [URLQueryItem(name: "page", value: String(page)),
                             URLQueryItem(name: "limit", value: "30")]
                let list = try await APIManager.shared.fetchImageList(query: query)
                if list.isEmpty {
                    let alert = UIAlertController(title: "마지막 페이지입니다.",
                                                  message: "더 이상 호출할 페이지가 없습니다.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(alert, animated: true)
                    return
                }
                images.append(contentsOf: list)
                page += 1
            } catch APIError.invalidURL{
                #if DEBUG
                debugPrint(APIError.invalidURL.description)
                #endif
            }
        }
    }
}

extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.thumbnail.image = nil
        cell.bind(model: images[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item + 1 == images.count {
            fetchImages()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailImageViewController()
        vc.imageInfo = images[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 2
        return CGSize(width: width, height: width)
    }
}
