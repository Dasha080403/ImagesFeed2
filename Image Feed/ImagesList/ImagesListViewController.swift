import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
       
       private let showSingleImageSegueIdentifier = "show"
       private var photos: [Photo] = []
       private let imagesListService = ImagesListService.shared
       private var imagesListServiceObserver: NSObjectProtocol?
       
       private lazy var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .long
           formatter.timeStyle = .none
           return formatter
       }()

       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
           
           setupNotificationObserver()
           imagesListService.fetchPhotosNextPage()
       }

    
    protocol ImagesListCellDelegate: AnyObject {
        func imageListCellDidTapLike(_ cell: ImagesListCell)
    }
    
    

    
    private func setupNotificationObserver() {
           imagesListServiceObserver = NotificationCenter.default
               .addObserver(
                   forName: ImagesListService.didChangeNotification,
                   object: nil,
                   queue: .main
               ) { [weak self] _ in
                   self?.updateTableViewAnimated()
               }
       }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        }
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath
                else { return }
                
                let photo = photos[indexPath.row]
                if let imageUrl = URL(string: photo.largeImageURL) {
                    viewController.fullImageUrl = imageUrl
                }
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }


// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// MARK: - Helpers
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.delegate = self
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "like_button_on")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Error changing like: \(error)")
            }
        }
    }
}
