//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 17.12.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
            didSet {
                guard isViewLoaded else { return } // 1
                imageView.image = image // 2
            }
        }
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButtonSingle: UIButton!
    @IBOutlet private var imageView: UIImageView!
   
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = image
        }
}
