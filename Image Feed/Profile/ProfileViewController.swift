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
    private var loginLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profileImageView: UIImageView? 
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupProfileImageView()
        setupNameLabel()
        setupLoginLabels()
        setupButton()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
            
            profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) {
                [weak self] _ in
                guard let self = self else { return }
                self.updateAvavtar()
            }
            updateAvavtar()
        }
    }

    private func updateAvavtar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let imageView = profileImageView 
        else { return }
        
        imageView.kf.setImage(with: url, placeholder: UIImage(resource: .userPhoto))
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name
        loginLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
    }

    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }

    private func setupProfileImageView() {
        let profileImage = UIImage(resource: .userPhoto)
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Сохраняем ссылку на imageView
        self.profileImageView = imageView
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
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

    private func setupLoginLabels() {
        let loginLabel = UILabel()
        loginLabel.textColor = UIColor(resource: .ypGray)
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)

        loginLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel!.bottomAnchor, constant: 8).isActive = true
        
        let textLabel = UILabel()
        textLabel.textColor = UIColor(resource: .ypWhite)
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        textLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
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
