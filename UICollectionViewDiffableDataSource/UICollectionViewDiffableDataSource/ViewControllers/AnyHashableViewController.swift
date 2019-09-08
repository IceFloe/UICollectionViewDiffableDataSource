//
//  AnyHashableViewController.swift
//  UICollectionViewDiffableDataSource
//
//  Created by Alex Gurin on 9/5/19.
//  Copyright © 2019 Alex Gurin. All rights reserved.
//

import UIKit

class AnyHashableViewController: UIViewController, UICollectionViewDelegate {
    enum Section: CaseIterable {
            case first
            case second
    }

    struct IntItem: Hashable {
        let id = UUID().uuidString
        var value: Int
    }

    struct StringItem: Hashable {
        let id = UUID().uuidString
        var value: String
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        collection.register(UINib(nibName: "TextCell", bundle: nil), forCellWithReuseIdentifier: TextCell.reuseIdentifier)

        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List"
        configureHierarchy()
        configureDataSource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collection.collectionViewLayout.invalidateLayout()
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

        return layout
    }

    private func configureHierarchy() {
        view.addSubview(collection)
        collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        collection.delegate = self
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collection) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TextCell.reuseIdentifier,
                for: indexPath) as? TextCell else { fatalError("Cannot create new cell") }

            // Populate the cell with our item description.
            switch item {
            case let item as IntItem:
                cell.configureWith(text: "Section \(indexPath.section), Row \(indexPath.row), Item \(item.value)")
            case let item as StringItem:
                cell.configureWith(text: "Section \(indexPath.section), Row \(indexPath.row), Item \(item.value)")
            default:
                ()
            }

            // Return the cell.
            return cell
        }

        // initial data
        dataSource.apply(dataSnapshot(), animatingDifferences: false)
    }

    func dataSnapshot() -> NSDiffableDataSourceSnapshot<Section, AnyHashable> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.first])
        snapshot.appendItems([IntItem(value: 5), IntItem(value: 8), IntItem(value: 10)], toSection: .first)
        snapshot.appendSections([.second])
        snapshot.appendItems([StringItem(value: "First"), StringItem(value: "Second"), StringItem(value: "Third")], toSection: .second)
        return snapshot
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
