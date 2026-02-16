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
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.2
        
        loadFullImage()
    }
    
    private func loadFullImage() {
        guard let fullImageUrl = fullImageUrl else { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageUrl) { [weak self] result in
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
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadFullImage()
        })
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.frame.size = image.size
            
            // 2. Обновляем contentSize у scrollView, чтобы он знал размер контента
            scrollView.contentSize = image.size
            
            // 3. Принудительно обновляем лейаут, чтобы получить актуальные bounds scrollView
            view.layoutIfNeeded()
            
            let visibleRectSize = scrollView.bounds.size
            let imageSize = image.size
            
            // 4. Расчет масштабов
            let hScale = visibleRectSize.width / imageSize.width
            let vScale = visibleRectSize.height / imageSize.height
            
            // Выбираем minScale, чтобы картинка вписалась целиком (Aspect Fit)
            let minScale = min(hScale, vScale)
            
            // 5. Настраиваем границы масштабирования
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 1.2
            
            // 6. Устанавливаем начальный масштаб
            scrollView.zoomScale = minScale
            
            // 7. Центрируем
            centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
           let contentSize = scrollView.contentSize
           
           let xOffset = max(0, (visibleRectSize.width - contentSize.width) / 2)
           let yOffset = max(0, (visibleRectSize.height - contentSize.height) / 2)
           
           scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
