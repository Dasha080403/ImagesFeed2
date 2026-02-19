import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let logoutService = ProfileLogoutService.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    func viewDidLoad() {
        view?.showSkeleton()
        
        if let profile = profileService.profile {
            updateView(with: profile)
        }
        
        observeAvatarChanges()
        
        checkAvatar()
    }

    func didTapLogout() {
            view?.showLogoutAlert()
        }
    
    func confirmLogout() {
           logoutService.logout()
       }

    private func updateView(with profile: Profile) {
        let name = profile.name
        let login = profile.loginName
        let bio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio!
        
        view?.displayProfileDetails(name: name, login: login, bio: bio)
    }

    private func checkAvatar() {
        if let urlString = profileImageService.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(with: url)
        }
    }

    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkAvatar()
        }
    }
}
