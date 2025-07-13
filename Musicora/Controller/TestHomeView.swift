import UIKit
import SnapKit

final class ScrollSegmentViewController: UIViewController, UIScrollViewDelegate {
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Şarkılar", "Sesli Kitaplar"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemPurple
        return control
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let songVC = SongListViewController()
    private let audiobookVC = DummyContentViewController(title: "Sesli Kitaplar", color: .systemOrange)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSegment()
        setupScrollView()
        setupChildControllers()
    }
    
    private func setupSegment() {
        view.addSubview(segmentControl)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(32)
        }
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(2)
        }
    }
    
    private func setupChildControllers() {
        addChild(songVC)
        addChild(audiobookVC)
        
        contentView.addSubview(songVC.view)
        contentView.addSubview(audiobookVC.view)
        
        songVC.didMove(toParent: self)
        audiobookVC.didMove(toParent: self)
        
        songVC.view.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        audiobookVC.view.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
    }
    
    @objc private func segmentChanged() {
        let index = segmentControl.selectedSegmentIndex
        let offsetX = CGFloat(index) * scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        segmentControl.selectedSegmentIndex = Int(pageIndex)
    }
}

final class DummyContentViewController: UIViewController {
    
    private let titleText: String
    private let backgroundColorSet: UIColor
    
    init(title: String, color: UIColor) {
        self.titleText = title
        self.backgroundColorSet = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColorSet
        
        let label = UILabel()
        label.text = titleText
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
