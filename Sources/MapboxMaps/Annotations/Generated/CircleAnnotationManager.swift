// This file is generated.
import Foundation
import os
@_implementationOnly import MapboxCommon_Private

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of ``CircleAnnotation`` being managed.
    public var annotations: [CircleAnnotation] {
        get {
            let allAnnotations = mainAnnotations.merging(draggedAnnotations) { $1 }
            return Array(allAnnotations.values)
        }
        set {
            mainAnnotations = newValue.reduce(into: [:]) { partialResult, annotation in
                partialResult[annotation.id] = annotation
            }

            draggedAnnotations = [:]
            annotationBeingDragged = nil
            needsSyncDragSource = true
        }
    }

    /// The collection of ``CircleAnnotation`` that has been dragged.
    private var draggedAnnotations: [String: CircleAnnotation] = [:]
    /// The collection of ``CircleAnnotation`` in the main source.
    private var mainAnnotations: [String: CircleAnnotation] = [:] {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    private var needsSyncSourceAndLayer = false
    private var needsSyncDragSource = false

    // MARK: - Interaction

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    /// - NOTE: This annotation manager listens to tap events via the `GestureManager.singleTapGestureRecognizer`.
    public weak var delegate: AnnotationInteractionDelegate?

    // MARK: - AnnotationManager protocol conformance

    public let sourceId: String

    public let layerId: String

    public let id: String

    // MARK: - Setup / Lifecycle

    /// Dependency required to add sources/layers to the map
    private let style: StyleProtocol

    /// Storage for common layer properties
    private var layerProperties: [String: Any] = [:] {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private let displayLinkParticipant = DelegatingDisplayLinkParticipant()

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    private let offsetPointCalculator: OffsetPointCalculator

    private var annotationBeingDragged: CircleAnnotation?

    private var isDestroyed = false
    private let dragLayerId: String
    private let dragSourceId: String

    var allLayerIds: [String] { [layerId, dragLayerId] }

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator?,
                  offsetPointCalculator: OffsetPointCalculator) {
        self.id = id
        self.sourceId = id
        self.layerId = id
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetPointCalculator = offsetPointCalculator
        self.dragLayerId = id + "_drag-layer"
        self.dragSourceId = id + "_drag-source"

        do {
            // Add the source with empty `data` property
            let source = GeoJSONSource(id: sourceId)
            try style.addSource(source)

            // Add the correct backing layer for this annotation type
            let layer = CircleLayer(id: layerId, source: sourceId)
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in CircleAnnotationManager. Error: \(error)",
                category: "Annotations")
        }

        self.displayLinkParticipant.delegate = self

        assert(displayLinkCoordinator != nil, "DisplayLinkCoordinator must be present")
        displayLinkCoordinator?.add(displayLinkParticipant)
    }

    internal func destroy() {
        guard !isDestroyed else {
            return
        }
        isDestroyed = true

        removeDragSourceAndLayer()

        do {
            try style.removeLayer(withId: layerId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove layer for CircleAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        do {
            try style.removeSource(withId: sourceId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove source for CircleAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        displayLinkCoordinator?.remove(displayLinkParticipant)
    }

    // MARK: - Sync annotations to map

    /// Synchronizes the backing source and layer with the current `annotations`
    /// and common layer properties. This method is called automatically with
    /// each display link, but it may also be called manually in situations
    /// where the backing source and layer need to be updated earlier.
    public func syncSourceAndLayerIfNeeded() {
        guard needsSyncSourceAndLayer, !isDestroyed else {
            return
        }
        needsSyncSourceAndLayer = false
        let allAnnotations = annotations

        // Construct the properties dictionary from the annotations
        let dataDrivenLayerPropertyKeys = Set(allAnnotations.flatMap(\.layerProperties.keys))
        let dataDrivenProperties = Dictionary(
            uniqueKeysWithValues: dataDrivenLayerPropertyKeys
                .map { (key) -> (String, Any) in
                    (key, ["get", key, ["get", "layerProperties"]] as [Any])
                })

        // Merge the common layer properties
        let newLayerProperties = dataDrivenProperties.merging(layerProperties, uniquingKeysWith: { $1 })

        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, StyleManager.layerPropertyDefaultValue(for: .circle, property: key).value)
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: layerId, properties: allLayerProperties)
        } catch {
            Log.error(
                forMessage: "Could not set layer properties in CircleAnnotationManager due to error \(error)",
                category: "Annotations")
        }

        // build and update the source data
        let featureCollection = FeatureCollection(features: mainAnnotations.values.map(\.feature))
        style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
    }

    private func syncDragSourceIfNeeded() {
        guard !isDestroyed, needsSyncDragSource else { return }

        needsSyncDragSource = false
        if style.sourceExists(withId: dragSourceId) {
            updateDragSource()
        }
    }

    // MARK: - Common layer properties

    /// Emission strength
    public var circleEmissiveStrength: Double? {
        get {
            return layerProperties["circle-emissive-strength"] as? Double
        }
        set {
            layerProperties["circle-emissive-strength"] = newValue
        }
    }

    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: CirclePitchAlignment? {
        get {
            return layerProperties["circle-pitch-alignment"].flatMap { $0 as? String }.flatMap(CirclePitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// Controls the scaling behavior of the circle when the map is pitched.
    public var circlePitchScale: CirclePitchScale? {
        get {
            return layerProperties["circle-pitch-scale"].flatMap { $0 as? String }.flatMap(CirclePitchScale.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-scale"] = newValue?.rawValue
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var circleTranslate: [Double]? {
        get {
            return layerProperties["circle-translate"] as? [Double]
        }
        set {
            layerProperties["circle-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `circle-translate`.
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        get {
            return layerProperties["circle-translate-anchor"].flatMap { $0 as? String }.flatMap(CircleTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["circle-translate-anchor"] = newValue?.rawValue
        }
    }

    // MARK: - User interaction handling

    /// Returns the first annotation matching the set of given `featureIdentifiers`.
    private func findAnnotation(from featureIdentifiers: [String], where predicate: (CircleAnnotation) -> Bool) -> CircleAnnotation? {
        for featureIdentifier in featureIdentifiers {
            if let annotation = mainAnnotations[featureIdentifier] ?? draggedAnnotations[featureIdentifier], predicate(annotation) {
                return annotation
            }
        }
        return nil
    }

    internal func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        guard annotations.map(\.id).contains(where: queriedFeatureIds.contains(_:)) else {
            return
        }

        var tappedAnnotations: [CircleAnnotation] = []
        var annotations: [CircleAnnotation] = []

        for var annotation in self.annotations {
            if queriedFeatureIds.contains(annotation.id) {
                annotation.isSelected.toggle()
                tappedAnnotations.append(annotation)
            }
            annotations.append(annotation)
        }

        self.annotations = annotations

        delegate?.annotationManager(
            self,
            didDetectTappedAnnotations: tappedAnnotations)
    }

    private func updateDragSource() {
        if let annotationBeingDragged = annotationBeingDragged {
            draggedAnnotations[annotationBeingDragged.id] = annotationBeingDragged
        }
        style.updateGeoJSONSource(withId: dragSourceId, geoJSON: .featureCollection(.init(features: draggedAnnotations.values.map(\.feature))))
    }

    private func updateDragLayer() {
        do {
            // copy the existing layer as the drag layer
            var properties = try style.layerProperties(for: layerId)
            properties[SymbolLayer.RootCodingKeys.id.rawValue] = dragLayerId
            properties[SymbolLayer.RootCodingKeys.source.rawValue] = dragSourceId

            if style.layerExists(withId: dragLayerId) {
                try style.setLayerProperties(for: dragLayerId, properties: properties)
            } else {
                try style.addPersistentLayer(with: properties, layerPosition: .above(layerId))
            }
        } catch {
            Log.error(forMessage: "Failed to update the layer to style. Error: \(error)")
        }
    }

    private func removeDragSourceAndLayer() {
        do {
            try style.removeLayer(withId: dragLayerId)
            try style.removeSource(withId: dragSourceId)
        } catch {
            Log.error(forMessage: "Failed to remove drag layer. Error: \(error)")
        }
    }

    internal func handleDragBegin(with featureIdentifiers: [String]) {
        guard let annotation = findAnnotation(from: featureIdentifiers, where: { $0.isDraggable }) else { return }

        do {
            if !style.sourceExists(withId: dragSourceId) {
                try style.addSource(GeoJSONSource(id: dragSourceId))
            }

            annotationBeingDragged = annotation
            mainAnnotations[annotation.id] = nil

            updateDragSource()
            updateDragLayer()
        } catch {
            Log.error(forMessage: "Failed to create the drag source to style. Error: \(error)")
        }
    }

    internal func handleDragChanged(with translation: CGPoint) {
        guard let annotationBeingDragged = annotationBeingDragged,
              let offsetPoint = offsetPointCalculator.geometry(for: translation, from: annotationBeingDragged.point) else {
            return
        }

        self.annotationBeingDragged?.point = offsetPoint
        updateDragSource()
    }

    internal func handleDragEnded() {
        annotationBeingDragged = nil
    }
}

extension CircleAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink,
                                            "Participant: CircleAnnotationManager") {
            syncSourceAndLayerIfNeeded()
            syncDragSourceIfNeeded()
        }
    }
}

// End of generated file.
