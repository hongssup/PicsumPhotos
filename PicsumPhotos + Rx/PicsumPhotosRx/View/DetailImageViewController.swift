//
//  DetailImageViewController.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/25.
//

import UIKit

final class DetailImageViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private var ratio: CGFloat?
    
    var imageInfo: Image? {
        didSet {
            if let imageInfo { bind(imageInfo) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        view.addSubview(authorLabel)
        
        let safeArea = view.safeAreaLayoutGuide
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(imageView.snp.width).multipliedBy(ratio ?? 1)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.equalTo(safeArea).offset(20)
        }
    }
    
    private func bind(_ imageInfo: Image) {
        title = imageInfo.id
        authorLabel.text = imageInfo.author
        ratio = CGFloat(imageInfo.height) / CGFloat(imageInfo.width)
        
        Task {
            do {
                imageView.image = try await ImageCacheManager.shared.getCachedImage(id: imageInfo.id, url: imageInfo.downloadUrl)
            } catch CacheError.invalidData {
                #if DEBUG
                debugPrint(CacheError.invalidData.description)
                #endif
            }
        }
    }
}
