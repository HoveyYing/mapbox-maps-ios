import CoreLocation

/**
 `DistanceFormatter` implements a formatter object meant to be used for
 geographic distances. The user’s current locale will be used by default
 but it can be overriden by changing the locale property of the numberFormatter.
 */
internal class DistanceFormatter: MeasurementFormatter {

    /// Returns a localized formatted string for the provided distance.
    ///
    /// - parameter distance: The distance, measured in meters.
    /// - returns: A localized formatted distance string including units.
    internal func string(fromDistance distance: CLLocationDistance, useMetricSystem: Bool? = nil) -> String {

        numberFormatter.roundingIncrement = 0.25

        var measurement = Measurement(value: distance, unit: UnitLength.meters)

        let shouldUseMetricSystem = useMetricSystem ?? locale.usesMetricSystem

        if shouldUseMetricSystem {
            unitOptions = [.providedUnit, .naturalScale]
        } else {
            unitOptions = .providedUnit
            measurement.convert(to: .miles)
            if measurement.value <= 0.2 {
                measurement.convert(to: .feet)
            }
        }
        
        var string = string(from: measurement)
        string = string.replacingOccurrences(of: "公里", with: "km")
        string = string.replacingOccurrences(of: "米", with: "m")
        return string
    }
}
