import UIKit
import MapKit

class OvalAnnotationView: MKAnnotationView {
    private var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let (title, subtitle) = self.createAnnotationTitles(title: annotation?.title!!, subtitle: annotation?.subtitle!!)
        self.view = UIView(frame: CGRect(x: 60, y: 78, width: 120, height: 50))
        view.backgroundColor = .white.withAlphaComponent(0.95)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.masksToBounds = false
        self.addSubview(self.view)
        
        self.view.layer.cornerRadius = view.frame.height / 2
        
        self.view.addSubview(title)
        self.view.addSubview(subtitle)
    }
    
    private func createAnnotationTitles(title: String?, subtitle: String?) -> (UILabel, UILabel) {
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 8, width: 80, height: 15))
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel(frame: CGRect(x: 20, y: 27, width: 80, height: 15))
        subtitleLabel.text = "GPS, \(subtitle ?? "")"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .gray
        
        return (titleLabel, subtitleLabel)
    }
}
