import CoreLocation
import UIKit
import MapboxCommon

/// An object responsible for managing user location Puck.
public final class LocationManager {
    /// A stream of location change events that drive the puck.
    public var onLocationChange: Signal<[Location]> { onLocationChangeProxy.signal }

    /// A stream of heading update events that drive the puck.
    ///
    /// Heading is used when puck uses ``PuckBearing/heading`` as a bearing type.
    public var onHeadingChange: Signal<Heading> { onHeadingChangeProxy.signal }

    /// A stream of puck render events.
    ///
    /// A subscriber will get the accurate (interpolated) data used to render puck,
    /// as opposed to the ``onLocationChange`` and ``onHeadingChange`` that emit non-interpolated source data.
    ///
    /// Observe this stream to adjust any elements that connected the actual puck position, such as route line, annotations, camera position,
    /// or you can render a custom puck.
    public let onPuckRender: Signal<PuckRenderingData>

    /// Configuration options for the location manager.
    public var options = LocationOptions() {
        didSet {
            puckManager.puckType = options.puckType
            puckManager.puckBearing = options.puckBearing
            puckManager.puckBearingEnabled = options.puckBearingEnabled
        }
    }

    /// Sets the custom providers that supply puck with the location data.
    ///
    /// - Parameters:
    ///   - locationProvider: Signal that drives puck location.
    ///   - headingProvider: Signal that drives the puck's bearing when it's configured as ``PuckBearing/heading``.
    public func override(
        locationProvider: Signal<[Location]>,
        headingProvider: Signal<Heading>? = nil
    ) {
        onLocationChangeProxy.proxied = locationProvider
        onHeadingChangeProxy.proxied = headingProvider
    }

    /// Sets the custom providers that supply puck with the location data.
    ///
    /// - Parameters:
    ///   - locationProvider: Provider that drives puck location.
    ///   - headingProvider: Provider that drives the puck's bearing when it's configured as ``PuckBearing/heading``.
    public func override(
        locationProvider: LocationProvider,
        headingProvider: HeadingProvider? = nil
    ) {
        // Patch the default location provider with the proper interface orientation view.
        (headingProvider as? AppleLocationProvider)?.orientationProvider?.view = interfaceOrientationView

        onLocationChangeProxy.proxied = locationProvider.toSignal()
        onHeadingChangeProxy.proxied = headingProvider?.toSignal()
    }

    /// Sets the custom provider that supply puck with the location and heading data.
    ///
    /// - Parameters:
    ///  - provider: An object that provides both location and heading data, such as ``AppleLocationProvider``.
    public func override(provider: LocationProvider & HeadingProvider) {
        self.override(locationProvider: provider, headingProvider: provider)
    }

    private let onLocationChangeProxy = CurrentValueSignalProxy<[Location]>()
    private let onHeadingChangeProxy = CurrentValueSignalProxy<Heading>()
    private let puckAnimator: ValueAnimator<PuckRenderingData?>
    private let puckManager: PuckManager
    private var interfaceOrientationView: Ref<UIView?>?

    convenience internal init(interfaceOrientationView: Ref<UIView?>,
                              displayLink: Signal<Void>,
                              styleManager: StyleProtocol,
                              mapboxMap: MapboxMapProtocol) {
        let provider = AppleLocationProvider()
        provider.orientationProvider?.view = interfaceOrientationView

        self.init(styleManager: styleManager,
                  mapboxMap: mapboxMap,
                  displayLink: displayLink,
                  locationProvider: Signal { provider.onLocationUpdate.observe($0) }, // retains provider
                  headingProvider: Signal { provider.onHeadingUpdate.observe($0) },
                  nowTimestamp: .now)
        self.interfaceOrientationView = interfaceOrientationView
    }

    internal init(styleManager: StyleProtocol,
                  mapboxMap: MapboxMapProtocol,
                  displayLink: Signal<Void>,
                  locationProvider: Signal<[Location]>,
                  headingProvider: Signal<Heading>,
                  nowTimestamp: Ref<Date>) {
        onLocationChangeProxy.proxied = locationProvider
        onHeadingChangeProxy.proxied = headingProvider

        let tracedDisplayLink = displayLink
            .tracingInterval(SignpostName.mapViewDisplayLink, "Participant: LocationManager")

        let locationInterpolator = LocationInterpolator()
        puckAnimator = ValueAnimator(
            ValueInterpolator(
                duration: 1.1,
                input: onLocationChangeProxy.signal,
                interpolate: locationInterpolator.interpolate(from:to:fraction:),
                nowTimestamp: nowTimestamp),
            ValueInterpolator(
                duration: 0.3,
                input: onHeadingChangeProxy.signal,
                interpolate: interpolateHeading(from:to:fraction:),
                nowTimestamp: nowTimestamp),
            trigger: tracedDisplayLink,
            reduce: PuckRenderingData.init(locations:heading:))

        // Skip frames where there are no data to display.
        onPuckRender = puckAnimator.output.skipNil()

        puckManager = PuckManager(
            puck2DProvider: { [onPuckRender] configuration in
                Puck2D(
                    configuration: configuration,
                    style: styleManager,
                    renderingData: onPuckRender,
                    mapboxMap: mapboxMap,
                    timeProvider: DefaultTimeProvider())
            },
            puck3DProvider: { [onPuckRender] configuration in
                Puck3D(
                    configuration: configuration,
                    style: styleManager,
                    renderingData: onPuckRender)
            })
    }

    /// Represents the latest location received from the location provider.
    ///
    /// - Note: The value is lazy and gets updated only when there is at least one consumer of location data,
    /// such as visible location puck or ``LocationManager/onLocationChange`` observer.
    ///
    /// In general, if you need to know the user location it's recommended to observe
    /// the ``LocationManager/onLocationChange`` instead.
    public var latestLocation: Location? {
        onLocationChange.latestValue?.last
    }

    /// Sets the custom providers that supply the map with the location data.
    @available(*, unavailable, message: "Use override(provider:) instead")
    public func overrideLocationProvider(with customLocationProvider: LocationProvider) {}

    /// The location manager holds weak references to consumers, client code should retain these references.
    @available(*, unavailable, message: "Use onLocationChange")
    public func addLocationConsumer(_ consumer: Void) {}

    /// Removes a location consumer from the location manager.
    @available(*, unavailable, message: "Use onLocationChange")
    public func removeLocationConsumer(_ consumer: Void) {}

    /// Adds  a puck location consumer to the location manager.
    @available(*, unavailable, message: "Use onPuckRender")
    public func addPuckLocationConsumer(_ consumer: Void) {}

    /// Removes a  puck location consumer from the location manager.
    @available(*, unavailable, message: "Use onPuckRender")
    public func removePuckLocationConsumer(_ consumer: Void) {}

    /// Allows a custom case to request full accuracy
    @available(*, unavailable, message: "Use AppleLocationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey:) instead")
    public func requestTemporaryFullAccuracyPermissions(withPurposeKey purposeKey: String) { fatalError() }

    /// The object that acts as the delegate of the location manager.
    @available(*, unavailable, message: "Use AppleLocationProvider.delegate instead")
    public weak var delegate: LocationPermissionsDelegate? { nil }

    /// The current location provider.
    /// Use this property to override the default (CoreLocation based) location provider with the supplied one.
    @available(*, unavailable, message: "Use onLocationChange instead")
    public var locationProvider: LocationProvider? { nil }
}
