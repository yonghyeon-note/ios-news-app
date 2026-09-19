//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Yonghyeon Kim on 9/19/26.
//

import Foundation

/* API에서 받은 데이터를 셀에서 표시하기 좋은 형태로 가공함 */
class NewsViewModel {
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil

    init(title: String, subtitle: String, imageURL: URL?) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
}
