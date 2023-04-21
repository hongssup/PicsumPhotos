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
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //view.backgroundColor = .blue
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        title = "ImageList"
        setupCollectionView()
    }
    
    func setupCollectionView() {
        view.addSubview(imageListCollectionView)
        
        let safeArea = view.safeAreaLayoutGuide
        imageListCollectionView.snp.makeConstraints {
            $0.edges.equalTo(safeArea)
        }
    }
}

extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .lightGray
        return cell
    }
}

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width / 3) - 2
        return CGSize(width: width, height: width)
    }
}
