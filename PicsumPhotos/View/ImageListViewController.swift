//
//  ImageListViewController.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/21.
//

import UIKit
import SnapKit

class ImageListViewController: UIViewController {
    
    lazy var imageListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    lazy var images: [Image] = [] {
        didSet {
            imageListCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        title = "ImageList"
        setupCollectionView()
        
        getImages()
    }
    
    private func setupCollectionView() {
        view.addSubview(imageListCollectionView)
        
        let safeArea = view.safeAreaLayoutGuide
        imageListCollectionView.snp.makeConstraints {
            $0.edges.equalTo(safeArea)
        }
    }
    
    private func getImages() {
        Task {
            do {
                self.images = try await APIManager.shared.fetchImageList()
                print(self.images)
            } catch {
                debugPrint("error")
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
        //cell.backgroundColor = .lightGray
        let urlStr = images[indexPath.item].downloadUrl
        Task {
            do {
                cell.thumbnail.image = try await APIManager.shared.fetchImage(url: urlStr)
            } catch {
                debugPrint("error")
            }
        }
        return cell
    }
}

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 2
        return CGSize(width: width, height: width)
    }
}
