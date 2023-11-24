import UIKit
import MapKit

final class PopupView: UIView {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var showHistoryButton: UIButton!
    
    @IBAction func showHistoryTapped(_ sender: UIButton) {
        print("showHistoryTapped")
    }
    
    static func instanceFromNib() -> PopupView {
        return UINib(nibName: "PopupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PopupView
    }
    
    func configure(with annotation: MKAnnotation, image: UIImage) {
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.borderWidth = 3
        userImageView.layer.borderColor = UIColor(hex: "#0075E3").cgColor
        showHistoryButton.layer.cornerRadius = showHistoryButton.frame.height / 2
        userNameLabel.text = annotation.title ?? ""
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let resultImage = renderer.image { context in
            let clipPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: image.size))
            clipPath.addClip()
            image.draw(in: userImageView.bounds)
        }
        userImageView.image = image
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        dateLabel.text = formattedDate
        
        dateFormatter.dateFormat = "HH:mm"
        let formattedTime = dateFormatter.string(from: currentDate)
        timeLabel.text = formattedTime
    }
}
