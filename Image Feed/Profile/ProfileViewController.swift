//
//  ProfileController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 11.12.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var textLabel: UILabel?
    private var avatarImageView: UIImageView!
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNameLabel()
        setupLabels()
        setupButton()
        avatarImageView = UIImageView()
        updateAvatar()

        if let profile = ProfileService.shared.profile {
                    updateProfileDetails(profile: profile)
        }
                
        profileImageServiceObserver = NotificationCenter.default
        .addObserver(
        forName: ProfileImageService.didChangeNotification,
        object: nil,
        queue: .main
        ) { [weak self] _ in
        guard let self = self else { return }
        self.updateAvatar()
        }
    }

private func updateAvatar() {
    guard
        let profileImageURL = ProfileImageService.shared.avatarURL,
        let imageUrl = URL(string: profileImageURL)
    else { return }

    print("imageUrl: \(imageUrl)")

    let placeholderImage = UIImage(systemName: "person.circle.fill")?
        .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

    let processor = RoundCornerImageProcessor(cornerRadius: 35)
    avatarImageView?.kf.indicatorType = .activity
    avatarImageView?.kf.setImage(
        with: imageUrl,
        placeholder: placeholderImage,
        options: [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .forceRefresh
        ]) { result in

            switch result {
            
            case .success(let value):
                
                print(value.image)

                // Откуда картинка загружена:
                // - .none — из сети.
                // - .memory — из кэша оперативной памяти.
                // - .disk — из дискового кэша.
                print(value.cacheType)

                // Информация об источнике.
                print(value.source)

                // В случае ошибки
            case .failure(let error):
                print(error)
            }
        }
}

private func updateProfileDetails(profile: Profile) {
    nameLabel?.text = profile.name.isEmpty
    ? "Имя не указано"
    : profile.name
    loginNameLabel?.text = profile.loginName.isEmpty
    ? "@неизвестный_пользователь"
    : profile.username
    textLabel?.text = (profile.bio?.isEmpty ?? true)
    ? "Профиль не заполнен"
    : profile.bio
}

    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }

    private func setupAvatarImageView() {
        
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        avatarImageView.widthAnchor.constraint(equalToConstant: 70),
        avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupNameLabel() {
        let nameLabel = UILabel()
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        if let imageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8).isActive = true
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        }
        
        self.nameLabel = nameLabel
    }

    private func setupLabels() {
        let loginNameLabel = UILabel()
        loginNameLabel.textColor = UIColor(resource: .ypGray)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel!.bottomAnchor, constant: 8).isActive = true
        self.loginNameLabel = loginNameLabel
    
    
        let textLabel = UILabel()
        textLabel.textColor = UIColor(resource: .ypWhite)
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        textLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        self.textLabel = textLabel
        }
    

    private func setupButton() {
            let button = UIButton.systemButton(
                with: UIImage(named: "Exit")!,
                target: self,
                action: #selector(didTapButton)
            )
            button.tintColor = UIColor(resource: .ypRed)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 44),
                button.heightAnchor.constraint(equalToConstant: 44),
                button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: (view.subviews.first(where: { $0 is UIImageView }) as? UIImageView)?.centerYAnchor ?? view.centerYAnchor)
            ])
        }

        @objc private func didTapButton() {
            
        }
}
