//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Yonghyeon Kim on 9/19/26.
//

import UIKit

final class NewsTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let identifier = "NewsTableViewCell"

    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 3
        return label
    }()


    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        /* 셀이 재사용되기 직전에 이전 값을 지워줌 */
        newsImageView.image = nil
        newsTitleLabel.text = nil
        subtitleLabel.text = nil
    }


    // MARK: - Helpers

    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subtitleLabel)

        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        newsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            newsImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            newsImageView.widthAnchor.constraint(equalToConstant: 140),

            newsTitleLabel.topAnchor.constraint(equalTo: newsImageView.topAnchor),
            newsTitleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 10),
            newsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            newsTitleLabel.heightAnchor.constraint(equalToConstant: 60),

            subtitleLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: newsImageView.bottomAnchor)
        ])
    }

    func configure(with viewModel: NewsViewModel) {
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageURL {
            /* 네트워크 요청이 끝나면 클로저가 실행됨
               이미지를 다운로드하고 있을 때 셀이 재사용될 수 있으므로 self를 약하게 참조함 */
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                /* data는 옵셔널 타입이므로 guard let 바인딩을 함 */
                guard let data = data, error == nil else { return }

                viewModel.imageData = data

                /* 이미지 뷰에 이미지를 넣는 건 UI 작업이므로 메인 스레드에서 해야 됨 */
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()  // 네트워크 요청을 시작함
        }
    }

}
