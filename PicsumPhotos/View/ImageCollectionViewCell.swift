//
//  ImageCollectionViewCell.swift
//  PicsumPhotos
//
//  Created by SeoYeon Hong on 2023/04/22.
//

import UIKit
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell {

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
}
