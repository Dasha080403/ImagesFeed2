//
//  ProfileController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 11.12.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var textLabel: UILabel?
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAvatarImageView()
        setupNameLabel()
        setupLabels()
        setupButton()
        updateAvatar()
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
                
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }

    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }

    private func setupAvatarImageView() {
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupNameLabel() {
        let label = UILabel()
        label.textColor = UIColor(resource: .ypWhite)
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
        
        self.nameLabel = label
    }

    private func setupLabels() {
        guard let nameLabel = nameLabel else { return }
        
        let loginLabel = UILabel()
        loginLabel.textColor = UIColor(resource: .ypGray)
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        let textLabel = UILabel()
        textLabel.textColor = UIColor(resource: .ypWhite)
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
        
        self.loginLabel = loginLabel
        self.textLabel = textLabel
    }

    private func setupButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit") ?? UIImage(),
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
            button.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }

    private func updateAvatar() {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else {
                print("DEBUG: URL аватарки пуст, используем заглушку")
                return
            }
            
            
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "person.crop.circle.fill"), 
                options: [.processor(processor)]
            )
    }

    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.username.isEmpty
        ? "Имя не указано"
        : profile.name
        loginLabel?.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        textLabel?.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }

    @objc private func didTapButton() { }
}
