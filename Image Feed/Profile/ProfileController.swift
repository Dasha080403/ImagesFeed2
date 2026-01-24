//
//  ProfileController.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 11.12.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var textLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupProfileImageView()
        setupNameLabel()
        setupAdditionalLabels()
        setupButton()
    }

    private func setupView() {
        view.backgroundColor = UIColor(named: "YP Black")
    }

    private func setupProfileImageView() {
        let profileImage = UIImage(named: "UserPhoto")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }

    private func setupNameLabel() {
        let nameLabel = UILabel()
        nameLabel.text = "Оксана Самойлова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = .boldSystemFont(ofSize: 23)
        //nameLabel.font = UIFont(name: "YS Display-Bold", size: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
       
        if let imageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8).isActive = true
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        }
        
        self.nameLabel = nameLabel
    }

    private func setupAdditionalLabels() {
        
        let loginLabel = UILabel()
        loginLabel.text = "@Oks"
        loginLabel.textColor = UIColor(named: "YP White")
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)

        
        loginLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel!.bottomAnchor, constant: 8).isActive = true
        

        
        let textLabel = UILabel()
        textLabel.text = "Мяу"
        textLabel.textColor = UIColor(named: "YP White")
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        
        textLabel.leadingAnchor.constraint(equalTo: nameLabel!.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
        //self.textLabel = textLabel
    }

    private func setupButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(didTapButton)
        )
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: (view.subviews.first(where: { $0 is UIImageView }) as? UIImageView)?.centerYAnchor ?? view.centerYAnchor).isActive = true
    }

    @objc private func didTapButton() {
        
    }
}
