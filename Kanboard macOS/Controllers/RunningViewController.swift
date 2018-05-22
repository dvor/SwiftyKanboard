//
//  RunningViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Cocoa
import SnapKit

class RunningViewController: NSViewController {
    let projectId = "3"

    private let synchronizationService: SynchronizationService?
    private var collectionViewDataSource: BoardCollectionViewDataSource!

    private var scrollView: NSScrollView!
    private var collectionView: NSCollectionView!

    init() {
        var synchronizationService: SynchronizationService? = nil

        do {
            let keychain = KeychainManager()

            synchronizationService = try SynchronizationService(projectIds: [projectId],
                                                                strategy: MacSynchronizationStrategy(),
                                                                baseURL: URL(string: keychain.baseURL!)!,
                                                                userName: keychain.userName!,
                                                                apiToken: keychain.apiToken!)
        } catch let error as NSError {
            let alert = NSAlert(error: error)
            alert.runModal()
        }

        self.synchronizationService = synchronizationService

        super.init(nibName: nil, bundle: nil)

        synchronizationService?.startSynchronization()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))

        createCollectionView()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addEvents()
    }
}

extension RunningViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.selectItems(at: indexPaths, scrollPosition: [.nearestHorizontalEdge, .nearestVerticalEdge])
    }
}

private extension RunningViewController {
    func createCollectionView() {
        scrollView = NSScrollView()
        view.addSubview(scrollView)

        collectionView = NSCollectionView()
        collectionViewDataSource = BoardCollectionViewDataSource(collectionView: collectionView, projectId: projectId)

        collectionView.collectionViewLayout = BoardCollectionViewLayout()
        collectionView.register(BoardCollectionViewItem.self, forItemWithIdentifier: BoardCollectionViewItem.identifier)
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
        collectionView.isSelectable = true
        scrollView.documentView = collectionView
    }

    func installConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    enum EventType {
        case left
        case right
        case down
        case up
    }

    func addEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in
            guard let `self` = self else { return event }
            guard let characters = event.characters else { return event }

            let type: EventType

            switch characters {
            case "h":
                type = .left
            case "l":
                type = .right
            case "j":
                type = .down
            case "k":
                type = .up
            default:
                return event
            }

            guard let selected = self.collectionView.selectionIndexPaths.first else {
                let path = IndexPath(item: 0, section: 0)
                self.collectionView.selectItems(at: [path], scrollPosition: [.nearestHorizontalEdge, .nearestVerticalEdge])
                return nil
            }

            var newSelected = selected

            switch type {
            case .left:
                if newSelected.section > 0 {
                    newSelected.section -= 1

                    let number = self.collectionView.numberOfItems(inSection: newSelected.section)
                    if newSelected.item >= number {
                        newSelected.item = number - 1
                    }
                }
            case .right:
                if (newSelected.section + 1) < self.collectionView.numberOfSections {
                    newSelected.section += 1

                    let number = self.collectionView.numberOfItems(inSection: newSelected.section)
                    if newSelected.item >= number {
                        newSelected.item = number - 1
                    }
                }
            case .down:
                if (newSelected.item + 1) < self.collectionView.numberOfItems(inSection: newSelected.section) {
                    newSelected.item += 1
                }
            case .up:
                if newSelected.item > 0 {
                    newSelected.item -= 1
                }
            }

            if selected == newSelected {
                return nil
            }

            self.collectionView.deselectItems(at: [selected])
            self.collectionView.selectItems(at: [newSelected], scrollPosition: [.nearestHorizontalEdge, .nearestVerticalEdge])

            return nil
        }
    }
}
