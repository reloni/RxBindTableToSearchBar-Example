//
//  NewsController.swift
//  TestTask
//
//  Created by Anton Efimenko on 07.06.2020.
//  Copyright © 2020 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NewsController: UIViewController{
    let bag = DisposeBag()
    
    private let tableView = UITableView().configure {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
    }
    
    let searchBar = UISearchBar().configure {
        $0.placeholder = "Enter article title"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        createConstraints()
        
        bind()
    }
    
    func bind() {
        searchBar.rx.text
        .orEmpty
        .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
        .flatMap { Self.searchNews($0) }
        .map { $0.articles }
        .asDriver(onErrorJustReturn: [])
        .drive(tableView.rx.items(cellIdentifier: "ArticleCell", cellType: UITableViewCell.self)) { (_, target, cell) in
            cell.textLabel?.text = target.title
        }
        .disposed(by: bag)
    }
    
    static func searchNews(_ searchString: String?) -> Single<NewsResults> {
        guard let string = searchString else { return Single.just(NewsResults(articles: [])) }
        guard string.count > 0 else { return Single.just(NewsResults(articles: [])) }
        return dataRequest(URLRequest.getNews(searchBy: string), in: URLSession.shared).decoded()
    }
    
    func createConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin)
            $0.leading.equalTo(view.snp.leadingMargin)
            $0.trailing.equalTo(view.snp.trailingMargin)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.leading.equalTo(view.snp.leadingMargin)
            $0.trailing.equalTo(view.snp.trailingMargin)
            $0.bottom.equalTo(view.snp.bottomMargin)
        }
    }
}
