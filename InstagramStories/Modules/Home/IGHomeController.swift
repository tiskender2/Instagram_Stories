//
//  IGHomeController.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

final class IGHomeController: UIViewController {
    
    //MARK: - iVars
    private var _view: IGHomeView { return view as! IGHomeView }
    private let viewModel: IGHomeViewModel
    
    //MARK: - Overridden functions
    
    init(viewModel: IGHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = IGHomeView(frame: UIScreen.main.bounds)
        _view.collectionView.delegate = self
        _view.collectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        viewModelObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    ///Custom Navigation Item with Cache button and Logo
    override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem()
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        if viewModel.isClearCacheEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .done, target: viewModel, action: #selector(viewModel.clearImageCache))
        }
        return navigationItem
    }
    
    //MARK: - Private functions
    private func viewModelObservers() {
        self.viewModel.showAlertMsg.bind {
            if let msg = $0 {
                self.showAlert(withMsg: msg)
            }
        }
        self.viewModel.presentPreviewScreen.bind {
            if let controller = $0 {
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
}

//MARK: - UICollectionViewDataSource
#warning("Instead of assinging self to UICollectionViewDataSource and keeping two methods one from viewcontroller and one from viewModel for numberOfItemsInSection, instead why dont go with ViewModel to keep the delegate and datasource methods there.")
#warning("if we are going to follow the above approach, then we are breaking the law. which says, ViewModel should not be aware of UserInterfact. So, you should not even import UIKit there.")
extension IGHomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.register(IGAddStoryCell.self, indexPath: indexPath)
            cell.userDetails = viewModel.presentUserDetails
            return cell
        } else {
            let cell =  collectionView.register(IGStoryListCell.self, indexPath: indexPath)
            cell.story = viewModel.cellForItemAt(indexPath: indexPath)
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension IGHomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(indexPath: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension IGHomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize: CGSize!
        if indexPath.row == 0 {
            itemSize = CGSize(width: 100, height: 100)
        }  else {
            itemSize = CGSize(width: 80, height: 100)
        }
        return itemSize
    }
}
