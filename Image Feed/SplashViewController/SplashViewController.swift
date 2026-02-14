//
//  SplashViewController.swift
//  Image Feed
//savinkina2003@mail.ru Dasha2003.
//  Created by Дарья Савинкина on 24.01.2026.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // 1. Закрываем экран авторизации
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // 2. Проверяем наличие токена после успешной авторизации
            guard let token = self.storage.token else { return }
            
            // 3. Загружаем профиль перед тем как пустить в TabBar
            self.fetchProfile(token: token)
        }
    }
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid Configuration")
                return
            }
            
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            
            window.rootViewController = tabBarController
        }
    }
    
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            // Переходим в главный поток перед вызовом ProfileImageService и переключением экрана
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    // Теперь это безопасно, так как мы в Main Thread
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    self.switchToTabBarController()
                case .failure:
                    print("ошибка!")
                    // Здесь стоит добавить показ алерта для пользователя
                }
            }
        }
    }
    }

    
    // MARK: - Navigation
    extension SplashViewController {
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as? AuthViewController
                else {
                    assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                    return
                }
                viewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }

    

