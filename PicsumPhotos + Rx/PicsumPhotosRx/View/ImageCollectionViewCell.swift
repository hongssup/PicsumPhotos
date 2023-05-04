//
//  ImageCollectionViewCell.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/22.
//

import UIKit
import SnapKit

final class ImageCollectionViewCell: UICollectionViewCell {

    lazy var thumbnail: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(thumbnail)
        contentView.backgroundColor = .systemGray6
        
        thumbnail.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(model: Image) {
        let newHeight = resizeHeight(width: model.width, height: model.height)
        let urlStr = Constants.API.imageURL + model.id + "/\(Constants.Value.newWidth)/\(newHeight)"
        
        Task {
            do {
                thumbnail.image = try await ImageCacheManager.shared.getCachedImage(id: model.id, url: urlStr)
            } catch CacheError.invalidURL {
                #if DEBUG
                debugPrint(CacheError.invalidURL.description)
                #endif
            }
        }
    }
    
    private func resizeHeight(width: Int, height: Int) -> Int {
        let scale = CGFloat(Constants.Value.newWidth) / CGFloat(width)
        let newHeight = CGFloat(height) * scale
        return Int(newHeight)
    }
}
