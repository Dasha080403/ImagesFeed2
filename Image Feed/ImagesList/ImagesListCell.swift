import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer? 
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        removeSkeleton()
    }

    func configure(with photo: Photo, dateString: String) {
        dateLabel.text = dateString
        setIsLiked(isLiked: photo.isLiked)
        
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        setSkeleton()
        
        cellImage.kf.indicatorType = .none
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "stub")) { [weak self] _ in
            self?.removeSkeleton()
        }
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }

    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Skeleton Logic
    
    private func setSkeleton() {
        if gradientLayer != nil { return }
        
        let gradient = SkeletonFactory.makeGradientLayer(for: cellImage)
        cellImage.layer.addSublayer(gradient)
        self.gradientLayer = gradient
    }
    
    private func removeSkeleton() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = cellImage.bounds
    }
}
