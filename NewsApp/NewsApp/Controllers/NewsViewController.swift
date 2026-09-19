//
//  ViewController.swift
//  NewsApp
//
//  Created by Yonghyeon Kim on 9/19/26.
//

import UIKit
import SafariServices

final class NewsViewController: UIViewController {

    // MARK: - Properties

    private var articles = [Article]()

    private var viewModels = [NewsViewModel]()

    private let newsTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupTableView()
        fetchTopStories()
    }


    // MARK: - Helpers

    private func setupNavigationBar() {
        title = "News"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupTableView() {
        view.addSubview(newsTableView)

        newsTableView.dataSource = self
        newsTableView.delegate = self

        newsTableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)

        newsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            newsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            newsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            newsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchTopStories() {
        /* getTopStories에서 completion이 호출되면 클로저가 실행됨 */
        APICaller.shared.getTopStories { [weak self] result in
            /* API 요청이 성공하면 Article 배열을 articles라는 이름으로 사용함 */
            switch result {
            case .success(let articles):
                self?.articles = articles
                /* Article 배열의 각 요소를 NewsViewModel로 변환해 viewModels에 저장함 */
                self?.viewModels = articles.compactMap({
                    NewsViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Description",
                        imageURL: URL(string: $0.urlToImage ?? "")
                    )
                })

                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}


// MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                 for: indexPath) as! NewsTableViewCell

        /* 테이블 뷰가 요청한 행에 해당하는 NewsViewModel을 셀에 전달함 */
        cell.configure(with: viewModels[indexPath.row])

        return cell
    }

}


// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* 셀을 탭했을 때 생긴 선택 표시를 해제함 */
        tableView.deselectRow(at: indexPath, animated: true)

        /* 탭한 행에 해당하는 Article을 저장함 */
        let article = articles[indexPath.row]

        /* article.url을 URL 타입으로 변환함 */
        guard let url = URL(string: article.url ?? "") else { return }

        /* 웹 페이지를 보여주는 Safari 화면을 생성함 */
        let safariVC = SFSafariViewController(url: url)

        present(safariVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

}
