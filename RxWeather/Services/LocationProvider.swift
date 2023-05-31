//
//  LocationService.swift
//  RxWeather
//
//  Created by Павло Сніжко on 25.05.2023.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

typealias LocationInfo = (city: String?, country: String?)

protocol LocationProviding {
    var locationObservable: Observable<CLLocationCoordinate2D> { get }
    var cityObservable: Observable<String> { get }
}

final class LocationProvider: NSObject, CLLocationManagerDelegate, LocationProviding {
    
    private let locationManager = CLLocationManager()
    
    private let locationSubject = ReplaySubject<CLLocationCoordinate2D>.create(bufferSize: 1)
    private let currentCity = ReplaySubject<String>.create(bufferSize: 1)
    
    private let restrictionSubject = PublishSubject<Void>()
    
    private var currentLocationCoord: CLLocation! {
        didSet {
            retrieveCityName()
        }
    }
    
    let disposeBag = DisposeBag()
    
    var locationObservable: Observable<CLLocationCoordinate2D> {
        return locationSubject.asObservable()
    }
    
    var cityObservable: Observable<String> {
        return currentCity.asObservable()
    }
    
    var restrictionObserver: Observable<Void> {
        restrictionSubject.asObservable()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocation()
    }
    
    private func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        //        locationManager.requestLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
            //TODO: Inform user about the restriction
            break
        case .denied:
            print("deined")
            // The user denied the use of location services for the app or they are disabled globally in Settings.
            // Direct them to re-enable this.
            break
        case .authorizedAlways, .authorizedWhenInUse:
            print("authorized")
            manager.requestLocation()
        @unknown default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        currentLocationCoord = location
        
        let coordinate = location.coordinate
        locationSubject.onNext(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.onError(error)
    }
    
    
    func retrieveCityName() {
        currentLocationCoord.fetchCityAndCountry()
            .asObservable()
            .compactMap { $0.city }
            .bind(to: currentCity)
            .disposed(by: disposeBag)
    }
}

extension LocationProvider {
    enum LocationError: Error {
        case undefinedCurrentLocation
    }
}


extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
    
    func fetchCityAndCountry() -> Single<LocationInfo> {
        return Single.create { single in
            CLGeocoder().reverseGeocodeLocation(self) { placemarks, error in
                if let error = error {
                    single(.failure(error))
                } else if let placemark = placemarks?.first {
                    let city = placemark.locality
                    let country = placemark.country
                    single(.success((city, country)))
                } else {
                    single(.success((nil, nil)))
                }
            }
            
            return Disposables.create()
        }
    }
}
