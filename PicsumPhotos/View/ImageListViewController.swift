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
    
    var page: Int = 2
    
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
                images = try await APIManager.shared.fetchImageList(query: [])
            } catch {
                debugPrint("getImages error")
            }
        }
    }
    
    private func loadMoreImages() {
        Task {
            do {
                let list = try await APIManager.shared.fetchImageList(query: [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "limit", value: "30")])
                images.append(contentsOf: list)
                page += 1
            } catch {
                debugPrint("loadMoreImages error")
                //마지막페이지입니다.
            }
        }
    }
    
    private func resizeHeight(newWidth: CGFloat, width: Int, height: Int) -> Int {
        let scale = newWidth / CGFloat(width)
        let newHeight = CGFloat(height) * scale
        return Int(newHeight)
    }
}

extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.thumbnail.image = nil
        let item = images[indexPath.item]
        let newWidth = 600
        let newHeight = resizeHeight(newWidth: CGFloat(newWidth), width: item.width, height: item.height)
        let id = item.id
        //let urlStr = images[indexPath.item].downloadUrl
        let urlStr = Constants.API.imageURL + id + "/\(newWidth)/\(newHeight)"
        Task {
            do {
                //cell.thumbnail.image = try await ImageCacheManager.shared.imageCache(url: urlStr)
                cell.thumbnail.image = try await ImageCacheManager.shared.getCachedImage(id: id, url: urlStr)
            } catch {
                debugPrint("collectionView error")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item + 1 == images.count {
            debugPrint("load more")
            loadMoreImages()
        }
    }
    
}

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 2
        return CGSize(width: width, height: width)
    }
}
