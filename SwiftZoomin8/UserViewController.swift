import UIKit
import Combine

final class UserViewController: UIViewController {
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
        
        // actor の property は await で呼ぶ必要があり
        // await を呼ぶために Task を利用する
        Task {
            await state
                .$user
                .receive(on: DispatchQueue.main)
                .sink { [weak self] user in
                    self?.nameLabel.text = user?.name
                }
                .store(in: &cancellables)

            await state
                .$iconImage
                .receive(on: DispatchQueue.main)
                .sink { [weak self] iconImage in
                    self?.iconImageView.image = iconImage
                }
                .store(in: &cancellables)
        }

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await state.loadUser()
        }
    }
}

// 警告を消すための暫定対応
extension Published.Publisher: @unchecked Sendable {}
