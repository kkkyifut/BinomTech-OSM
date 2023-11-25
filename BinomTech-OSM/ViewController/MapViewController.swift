import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var mapController: MapController?
    private var mapModel = MapModel()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var nextTrackerButton: UIButton!

    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func zoomInTapped(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta *= 0.5
        region.span.longitudeDelta *= 0.5
        mapController?.limitMapZoom(with: region.span)
    }
    
    @IBAction func zoomOutTapped(_ sender: UIButton) {
        var region = mapView.region
        region.span.latitudeDelta *= 2.0
        region.span.longitudeDelta *= 2.0
        mapController?.limitMapZoom(with: region.span)
    }
    
    @IBAction func nextTrackerButtonTapped(_ sender: UIButton) {
        if mapModel.currentAnnotationIndex < mapModel.annotations.count {
            let nextAnnotation = mapModel.annotations[mapModel.currentAnnotationIndex]
            mapView.selectAnnotation(nextAnnotation, animated: true)
            mapModel.currentAnnotationIndex += 1
        } else {
            if let firstAnnotation = mapModel.annotations.first {
                mapView.selectAnnotation(firstAnnotation, animated: true)
            }
            mapModel.currentAnnotationIndex = 1
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        mapController = MapController(mapView: mapView, model: mapModel)
        mapController?.setupMap()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addOpenStreetMapOverlay()
        addGestureRecognizersToMap()
    }

    func addOpenStreetMapOverlay() {
        let overlay = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addGestureRecognizersToMap() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressTap(gesture:)))
        pressGesture.delegate = self
        mapView.addGestureRecognizer(pressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMapPan(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
    }
    
    @objc func pressTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationInView = gesture.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            mapController?.addAnnotation(at: tappedCoordinate)
        }
    }
    
    @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        closePopupView()
    }
    
    @objc func handleMapPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        closePopupView()
    }
    
    private func closePopupView() {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
        mapController?.removePopupView()
    }
}
