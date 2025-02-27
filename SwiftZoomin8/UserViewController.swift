import UIKit
import Combine

// UIViewController は Sendable だが Compiler に対して @MainActor することで state の警告が消える
@MainActor final class UserViewController: UIViewController {
    let state: UserViewState
    
    private let iconImageView: UIImageView = .init()
    private let nameLabel: UILabel = .init()
    
    private var cancellables: Set<AnyCancellable> = []

    init(id: User.ID) {
        self.state = UserViewState(id: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // レイアウト
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 40
        iconImageView.layer.borderWidth = 4
        iconImageView.layer.borderColor = UIColor.systemGray3.cgColor
        iconImageView.clipsToBounds = true
        view.addSubview(iconImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
        ])

        // View への反映
        
        // actor の property は await で呼ぶ必要があり
        // await を呼ぶために Task を利用する
        let task = Task { [weak self] in
            guard let state = self?.state else { return }
            // UserViewState が ObservableObect に適合しているので objectWillChange でまとめて購読できる
            for await _ in state.objectWillChange.values {
                guard let self = self else { return }
                // 片方が更新されても両方更新が走るので、 View によっては注意が必要
                // await しているので willChange で発火し、反映する時は didChange 後の値となる想定
                self.nameLabel.text = state.user?.name
                self.iconImageView.image = state.iconImage
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await state.loadUser()
        }
    }
}

extension UIImage: @unchecked Sendable {}
