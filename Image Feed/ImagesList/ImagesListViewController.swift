import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImagesListViewOutput? 
    private let showSingleImageSegueIdentifier = "show"

    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            let presenter = ImagesListPresenter()
            presenter.view = self
            self.presenter = presenter
        }
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter?.getPhoto(at: indexPath.row),
           let imageUrl = URL(string: photo.largeImageURL) {
            viewController.fullImageUrl = imageUrl
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - ImagesListViewInput
extension ImagesListViewController: ImagesListViewInput {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    func setCellLikeState(at indexPath: IndexPath, isLiked: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setIsLiked(isLiked: isLiked)
        }
    }

    func showProgressHUD() { UIBlockingProgressHUD.show() }
    func hideProgressHUD() { UIBlockingProgressHUD.dismiss() }
    
    func showError(message: String) {
        print(message)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotosCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell, let presenter = presenter else {
            return UITableViewCell()
        }
        
        let photo = presenter.getPhoto(at: indexPath.row)
        let dateString = presenter.getCellDateString(at: indexPath.row)
        
        imageListCell.delegate = self
        imageListCell.configure(with: photo, dateString: dateString)
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.calculateCellHeight(at: indexPath.row, containerWidth: tableView.bounds.width) ?? 0
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
