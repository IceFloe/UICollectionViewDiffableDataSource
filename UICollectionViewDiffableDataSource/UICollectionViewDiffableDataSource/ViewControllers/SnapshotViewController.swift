//
//  SnapshotViewController.swift
//  UICollectionViewCompositionalLayout
//
//  Created by Alex Gurin on 8/25/19.
//

import UIKit

class SnapshotViewController: UIViewController, UICollectionViewDelegate {

    enum Section {
        case first
        case second
        case third
    }

    struct Item: Hashable {
        let id = UUID().uuidString
        var value: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id
        }
    }
//    class Item: Hashable {
//        let id = UUID().uuidString
//        var value: Int
//
//        init(value: Int) {
//            self.value = value
//        }
//
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//        }
//
//        static func == (lhs: Item, rhs: Item) -> Bool {
//            return lhs.id == rhs.id
//        }
//    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        collection.register(UINib(nibName: "TextCell", bundle: nil), forCellWithReuseIdentifier: TextCell.reuseIdentifier)

        return collection
    }()
    lazy var insertBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Insert", for: .normal)
        btn.addTarget(self, action: #selector(insertItem), for: .touchUpInside)
        return btn
    }()
    lazy var deleteBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Delete", for: .normal)
        btn.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        return btn
    }()
    lazy var moveBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Move", for: .normal)
        btn.addTarget(self, action: #selector(moveItem), for: .touchUpInside)
        return btn
    }()
    lazy var reloadBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Reload", for: .normal)
        btn.addTarget(self, action: #selector(reloadItem), for: .touchUpInside)
        return btn
    }()
    lazy var insertSectionBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Insert Section", for: .normal)
        btn.addTarget(self, action: #selector(insertSection), for: .touchUpInside)
        return btn
    }()
    lazy var deleteSectionBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Delete Section", for: .normal)
        btn.addTarget(self, action: #selector(deleteSection), for: .touchUpInside)
        return btn
    }()
    lazy var moveSectionBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Move Section", for: .normal)
        btn.addTarget(self, action: #selector(moveSection), for: .touchUpInside)
        return btn
    }()
    lazy var reloadSectionBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.setTitle("Reload Section", for: .normal)
        btn.addTarget(self, action: #selector(reloadSection), for: .touchUpInside)
        return btn
    }()
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var hStackItem: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    lazy var hStackSection: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
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
        hStackItem.addArrangedSubview(insertBtn)
        hStackItem.addArrangedSubview(deleteBtn)
        hStackItem.addArrangedSubview(moveBtn)
        hStackItem.addArrangedSubview(reloadBtn)
        hStackSection.addArrangedSubview(insertSectionBtn)
        hStackSection.addArrangedSubview(deleteSectionBtn)
        hStackSection.addArrangedSubview(moveSectionBtn)
        hStackSection.addArrangedSubview(reloadSectionBtn)
        vStack.addArrangedSubview(hStackItem)
        vStack.addArrangedSubview(hStackSection)
        view.addSubview(vStack)
        view.addSubview(collection)

        vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        vStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vStack.heightAnchor.constraint(equalToConstant: 70).isActive = true

        collection.topAnchor.constraint(equalTo: vStack.bottomAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        collection.delegate = self
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collection) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TextCell.reuseIdentifier,
                for: indexPath) as? TextCell else { fatalError("Cannot create new cell") }

            // Populate the cell with our item description.
            cell.configureWith(text: "Section \(indexPath.section), Row \(indexPath.row), Item \(item.value)")

            // Return the cell.
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.first, .second])
        snapshot.appendItems(Array(0...4).map { Item(value: $0) }, toSection: .first)
        snapshot.appendItems(Array(5...9).map { Item(value: $0) }, toSection: .second)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SnapshotViewController {
    @objc func insertItem() {
        var snapshot = dataSource.snapshot()
        snapshot.insertItems([Item(value: 33)], afterItem: snapshot.itemIdentifiers[2])
        snapshot.insertItems([Item(value: 22)], afterItem: snapshot.itemIdentifiers[6])
        UIView.animate(withDuration: 2) {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    @objc func deleteItem() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([snapshot.itemIdentifiers[2]])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func moveItem() {
        var snapshot = dataSource.snapshot()
        snapshot.moveItem(snapshot.itemIdentifiers[2], afterItem: snapshot.itemIdentifiers[4])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func reloadItem() {
        var snapshot = dataSource.snapshot()
        var item = snapshot.itemIdentifiers[2]
        item.value = Int.random(in: 1...25)
        snapshot.deleteItems([item])
        snapshot.insertItems([item], beforeItem: snapshot.itemIdentifiers[2])
        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func insertSection() {
        var snapshot = dataSource.snapshot()
        snapshot.insertSections([.third], beforeSection: .second)
        snapshot.appendItems([Item(value: 33),Item(value: 22)], toSection: .third)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func deleteSection() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.second])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func moveSection() {
        var snapshot = dataSource.snapshot()
        snapshot.moveSection(snapshot.sectionIdentifiers[0], afterSection: snapshot.sectionIdentifiers[1])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func reloadSection() {
        var snapshot = dataSource.snapshot()
        var items = snapshot.itemIdentifiers(inSection: .first)
        snapshot.deleteItems(items)
        for (index, _) in items.enumerated() {
            items[index].value = Int.random(in: 1...100)
        }
        snapshot.appendItems(items, toSection: .first)
        snapshot.reloadSections([.first])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
