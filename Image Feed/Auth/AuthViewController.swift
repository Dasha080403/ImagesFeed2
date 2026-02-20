//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 24.01.2026. Dasha2003.
//

import UIKit
import WebKit
import ProgressHUD


protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    @IBOutlet private weak var logImage: UIImageView!
    @IBOutlet private weak var logButton: UIButton!
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private var isAuthenticating = false
    private let storage = OAuth2TokenStorage.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
                guard let webViewViewController = segue.destination as? WebViewViewController else {
                    assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                    return
                }
                let authHelper = WebViewHelper()
                let webViewPresenter = WebViewPresenter(authHelper: authHelper)
                
                webViewViewController.presenter = webViewPresenter
                webViewPresenter.view = webViewViewController
                webViewViewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.authViewController(self, didAuthenticateWithCode: code)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}
