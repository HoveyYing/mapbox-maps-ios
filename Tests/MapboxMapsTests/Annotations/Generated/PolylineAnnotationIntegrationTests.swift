// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolylineAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolylineAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePolylineAnnotationManager()
    }

    override func tearDownWithError() throws {
        manager = nil
        try super.tearDownWithError()
    }

    internal func testSourceAndLayerSetup() throws {
        XCTAssertTrue(mapView.mapboxMap.layerExists(withId: manager.layerId))
        XCTAssertTrue(try mapView.mapboxMap.isPersistentLayer(id: manager.layerId),
                      "The layer with id \(manager.layerId) should be persistent.")
        XCTAssertTrue(mapView.mapboxMap.sourceExists(withId: manager.sourceId))
    }

    func testSourceAndLayerRemovedUponDestroy() {
        manager.destroy()

        XCTAssertFalse(mapView.mapboxMap.allLayerIdentifiers.map { $0.id }.contains(manager.layerId))
        XCTAssertFalse(mapView.mapboxMap.allSourceIdentifiers.map { $0.id }.contains(manager.sourceId))
    }

    func testCreatingSecondAnnotationManagerWithTheSameId() throws {
        let secondAnnotationManager = mapView.annotations.makePolylineAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineWidth = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self) else {
                return false
            }
            return layer.lineWidth == .expression(Exp(.number) {
                Exp(.get) {
                    "line-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            })
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLineCap() throws {
        // Test that the setter and getter work
        let value = LineCap.random()
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineCap {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineCap = nil
        XCTAssertNil(manager.lineCap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineCap, .constant(LineCap(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String)))
    }

    func testLineMiterLimit() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineMiterLimit {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineMiterLimit = nil
        XCTAssertNil(manager.lineMiterLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineMiterLimit, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! NSNumber).doubleValue))
    }

    func testLineRoundLimit() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineRoundLimit {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineRoundLimit = nil
        XCTAssertNil(manager.lineRoundLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineRoundLimit, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! NSNumber).doubleValue))
    }

    func testLineDasharray() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineDasharray {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineDasharray = nil
        XCTAssertNil(manager.lineDasharray)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDasharray, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]))
    }

    func testLineDepthOcclusionFactor() throws {
        // Test that the setter and getter work
        let value = Double.random(in: 0...1)
        manager.lineDepthOcclusionFactor = value
        XCTAssertEqual(manager.lineDepthOcclusionFactor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineDepthOcclusionFactor {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineDepthOcclusionFactor = nil
        XCTAssertNil(manager.lineDepthOcclusionFactor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDepthOcclusionFactor, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-depth-occlusion-factor").value as! NSNumber).doubleValue))
    }

    func testLineEmissiveStrength() throws {
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        manager.lineEmissiveStrength = value
        XCTAssertEqual(manager.lineEmissiveStrength, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineEmissiveStrength {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineEmissiveStrength = nil
        XCTAssertNil(manager.lineEmissiveStrength)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testLineTranslate() throws {
        // Test that the setter and getter work
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTranslate = nil
        XCTAssertNil(manager.lineTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]))
    }

    func testLineTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = LineTranslateAnchor.random()
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTranslateAnchor = nil
        XCTAssertNil(manager.lineTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslateAnchor, .constant(LineTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String)))
    }

    func testLineTrimOffset() throws {
        // Test that the setter and getter work
        let value = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()
        manager.lineTrimOffset = value
        XCTAssertEqual(manager.lineTrimOffset, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTrimOffset {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTrimOffset = nil
        XCTAssertNil(manager.lineTrimOffset)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTrimOffset, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-offset").value as! [Double]))
    }

    func testLineJoin() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = LineJoin.random()
        annotation.lineJoin = value
        XCTAssertEqual(annotation.lineJoin, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineJoin, .expression(Exp(.toString) {
                Exp(.get) {
                    "line-join"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineJoin = nil
        XCTAssertNil(annotation.lineJoin)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineJoin, .constant(LineJoin(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-join").value as! String)))
    }

    func testLineSortKey() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.lineSortKey = value
        XCTAssertEqual(annotation.lineSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineSortKey, .expression(Exp(.number) {
                Exp(.get) {
                    "line-sort-key"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineSortKey = nil
        XCTAssertNil(annotation.lineSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineSortKey, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-sort-key").value as! NSNumber).doubleValue))
    }

    func testLineBlur() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineBlur = value
        XCTAssertEqual(annotation.lineBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBlur, .expression(Exp(.number) {
                Exp(.get) {
                    "line-blur"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineBlur = nil
        XCTAssertNil(annotation.lineBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBlur, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-blur").value as! NSNumber).doubleValue))
    }

    func testLineBorderColor() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.lineBorderColor = value
        XCTAssertEqual(annotation.lineBorderColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "line-border-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineBorderColor = nil
        XCTAssertNil(annotation.lineBorderColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-color").value as! [Any], options: []))))
    }

    func testLineBorderWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineBorderWidth = value
        XCTAssertEqual(annotation.lineBorderWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "line-border-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineBorderWidth = nil
        XCTAssertNil(annotation.lineBorderWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-width").value as! NSNumber).doubleValue))
    }

    func testLineColor() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.lineColor = value
        XCTAssertEqual(annotation.lineColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "line-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineColor = nil
        XCTAssertNil(annotation.lineColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-color").value as! [Any], options: []))))
    }

    func testLineGapWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineGapWidth = value
        XCTAssertEqual(annotation.lineGapWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineGapWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "line-gap-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineGapWidth = nil
        XCTAssertNil(annotation.lineGapWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineGapWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-gap-width").value as! NSNumber).doubleValue))
    }

    func testLineOffset() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.lineOffset = value
        XCTAssertEqual(annotation.lineOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOffset, .expression(Exp(.number) {
                Exp(.get) {
                    "line-offset"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineOffset = nil
        XCTAssertNil(annotation.lineOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOffset, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-offset").value as! NSNumber).doubleValue))
    }

    func testLineOpacity() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: 0...1)
        annotation.lineOpacity = value
        XCTAssertEqual(annotation.lineOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "line-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineOpacity = nil
        XCTAssertNil(annotation.lineOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-opacity").value as! NSNumber).doubleValue))
    }

    func testLinePattern() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = String.randomASCII(withLength: .random(in: 0...100))
        annotation.linePattern = value
        XCTAssertEqual(annotation.linePattern, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.linePattern, .expression(Exp(.image) {
                Exp(.get) {
                    "line-pattern"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.linePattern = nil
        XCTAssertNil(annotation.linePattern)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.linePattern, .constant(.name(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-pattern").value as! String)))
    }

    func testLineWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineWidth = value
        XCTAssertEqual(annotation.lineWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "line-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineWidth = nil
        XCTAssertNil(annotation.lineWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width").value as! NSNumber).doubleValue))
    }
}

// End of generated file
