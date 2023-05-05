//
//  ImageViewModel.swift
//  PicsumPhotosRx
//
//  Created by SeoYeon Hong on 2023/05/04.
//

import Foundation
import RxSwift
import RxCocoa

final class ImageViewModel {
    
    var page = 1
    var isFetchingData = false
    let imageList = BehaviorRelay<[Image]>(value: [])
    let disposeBag = DisposeBag()
    
    func fetchImages() {
        if isFetchingData { return }
        isFetchingData = true
        
        let query = [URLQueryItem(name: "page", value: String(page)),
                     URLQueryItem(name: "limit", value: "30")]
        
        APIManager.shared.fetchImageListRx(query: query)
            .subscribe(onNext: { result in
                var tempResult = self.imageList.value
                tempResult.append(contentsOf: result)
                self.imageList.accept(tempResult)
            }, onError: { error in
                debugPrint(error)
            }, onCompleted: {
                self.isFetchingData = false
                self.page += 1
            })
            .disposed(by: disposeBag)
    }
}
