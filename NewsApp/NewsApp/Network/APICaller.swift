//
//  APICaller.swift
//  NewsApp
//
//  Created by Yonghyeon Kim on 9/19/26.
//

import Foundation

final class APICaller {
    static let shared = APICaller()

    private struct Constants {
        static let topHeadlinesURL = URL(
            string: "https://newsapi.org/v2/top-headlines?country=us&apiKey="
        )
    }

    private init() {}

    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        /* topHeadlinesURL은 옵셔널 타입이므로 guard let 바인딩을 함 */
        guard let url = Constants.topHeadlinesURL else { return }

        /* 네트워크 요청이 끝나면 클로저가 실행됨 */
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    /* API에서 받은 JSON 데이터를 Swift 모델(NewsResponse)로 변환함 */
                    let result = try JSONDecoder().decode(NewsResponse.self, from: data)

                    // print("Articles: \(result.articles.count)")

                    /* 전달받은 클로저에 Article 배열을 전달함 */
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()  // 네트워크 요청을 시작함
    }
}
