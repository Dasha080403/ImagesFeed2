//
//  ProfilePresenterProtocl.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 19.02.2026.
//

import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(with url: URL) 
    func showSkeleton()
    func hideSkeleton()
    func showLogoutAlert()
}

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

