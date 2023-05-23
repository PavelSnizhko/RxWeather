//
//  MetricViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

struct Metric {
    let icon: UIImage
    let valueString: String
    let title: String
}

struct MetricViewModel {
    let metrics: [Metric] = [
        Metric(icon: UIImage(named: "carbon_humidity")!, valueString: "75%", title: "Humidity"),
        Metric(icon: UIImage(named: "ic_round-visibility")!, valueString: "8 km/h", title: "Wind"),
        Metric(icon: UIImage(named: "ion_speedometer")!, valueString: "1011", title: "Air Prressure"),
        Metric(icon: UIImage(named: "tabler_wind")!, valueString: "6 km", title: "Visibility")
    ]
}
