import MapKit

class MapController: NSObject {
    private let mapView: MKMapView
    private let mapModel: MapModel
    private var popupView: PopupView?
    private let userImage = UIImage(named: "yuriy")
    private var currentSpan: MKCoordinateSpan?
    
    init(mapView: MKMapView, model: MapModel) {
        self.mapView = mapView
        self.mapModel = model
        super.init()
    }
    
    func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func removePopupView() {
        popupView?.removeFromSuperview()
        popupView = nil
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = ["Юрий", "Илья", "Михаил", "Иван", "Максим", "Алексей"].randomElement()!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentDate = Date()
        let formattedTime = dateFormatter.string(from: currentDate)
        
        annotation.subtitle = formattedTime
        mapView.addAnnotation(annotation)
        if annotation.title != mapView.userLocation.title {
            mapModel.annotations.append(annotation)
        }
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        removePopupView()
        popupView = PopupView.instanceFromNib()
        popupView?.frame = mapView.bounds
        popupView?.frame.origin.y = popupView!.cardView.frame.height
        popupView?.configure(with: annotation, image: userImage!)
        mapView.addSubview(popupView!)
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.popupView?.frame.origin.y = 0
        })
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        removePopupView()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let reuseIdentifier = "customPinLocation"
            var locationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if locationView == nil {
                locationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                locationView?.image = UIImage(named: "ic_my_tracker_46dp")
            } else {
                locationView?.annotation = annotation
            }
            locationView?.isUserInteractionEnabled = false
            return locationView
        } else {
            let reuseIdentifier = "customPin"
            let annotationView = OvalAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            
            let tracker = UIImageView(image: UIImage(named: "ic_tracker_75dp"))
            tracker.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            let user = UIImageView(image: userImage)
            user.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
            user.layer.cornerRadius = user.frame.height / 2
            user.clipsToBounds = true
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
            let resultImage = renderer.image { context in
                tracker.image!.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
                let clipPath = UIBezierPath(ovalIn: CGRect(x: 15, y: 7, width: 70, height: 70))
                clipPath.addClip()
                user.image!.draw(in: CGRect(x: 15, y: 7, width: 70, height: 70))
            }
            
            annotationView.image = resultImage
            annotationView.collisionMode = .circle
            annotationView.canShowCallout = false
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        currentSpan = mapView.region.span
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region
        limitMapZoom(with: region.span)
    }
    
    func limitMapZoom(with span: MKCoordinateSpan) {
        var span = span
        let minLatitudeDelta: CLLocationDegrees = 0.0013
        let minLongitudeDelta: CLLocationDegrees = 0.0013
        
        if span.latitudeDelta < minLatitudeDelta {
            span.latitudeDelta = minLatitudeDelta
        }
        
        if span.longitudeDelta < minLongitudeDelta {
            span.longitudeDelta = minLongitudeDelta
        }
        
        var region = mapView.region
        region.span = span
        
        mapView.setRegion(region, animated: true)
    }
}
