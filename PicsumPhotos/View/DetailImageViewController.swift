//
//  DetailImageViewController.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/25.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    var ratio: CGFloat = 1
    
    var imageInfo: Image? {
        didSet {
            //print("imageInfo:\(imageInfo)")
            title = imageInfo?.id
            authorLabel.text = imageInfo?.author
            ratio = CGFloat(imageInfo?.height ?? 1) / CGFloat(imageInfo?.width ?? 1)
            Task {
                do {
                    imageView.image = try await ImageCacheManager.shared.getCachedImage(id: imageInfo!.id, url: imageInfo!.downloadUrl)
                } catch CacheError.invalidData {
                    #if DEBUG
                    debugPrint(CacheError.invalidData.description)
                    #endif
                }
            }
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
            $0.height.equalTo(imageView.snp.width).multipliedBy(ratio)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.equalTo(safeArea).offset(20)
        }
    }
}
