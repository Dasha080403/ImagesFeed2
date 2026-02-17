//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 17.12.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
  
    var fullImageUrl: URL?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        scrollView.delegate = self
      
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.2
        
        loadImage()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadImage() {
        guard let url = fullImageUrl else { return }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.frame.size = image.size
        scrollView.contentSize = image.size
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let minScale = min(hScale, vScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        
        centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let xOffset = max(0, (visibleRectSize.width - contentSize.width) / 2)
        let yOffset = max(0, (visibleRectSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
