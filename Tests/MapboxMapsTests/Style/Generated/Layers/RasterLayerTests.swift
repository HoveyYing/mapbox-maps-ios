// This file is generated
import XCTest
@testable import MapboxMaps

final class RasterLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = RasterLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.raster)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = RasterLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode RasterLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.raster)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
        } catch {
            XCTFail("Failed to decode RasterLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = RasterLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode RasterLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
        } catch {
            XCTFail("Failed to decode RasterLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = RasterLayer(id: "test-id", source: "source")
       layer.rasterBrightnessMax = Value<Double>.testConstantValue()
       layer.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterBrightnessMin = Value<Double>.testConstantValue()
       layer.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterColor = Value<StyleColor>.testConstantValue()
       layer.rasterColorMix = Value<[Double]>.testConstantValue()
       layer.rasterColorMixTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterColorRange = Value<[Double]>.testConstantValue()
       layer.rasterColorRangeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterContrast = Value<Double>.testConstantValue()
       layer.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterFadeDuration = Value<Double>.testConstantValue()
       layer.rasterHueRotate = Value<Double>.testConstantValue()
       layer.rasterHueRotateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterOpacity = Value<Double>.testConstantValue()
       layer.rasterOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterResampling = Value<RasterResampling>.testConstantValue()
       layer.rasterSaturation = Value<Double>.testConstantValue()
       layer.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode RasterLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode RasterLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.rasterBrightnessMax, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterBrightnessMin, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.rasterColorMix, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.rasterColorRange, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.rasterContrast, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterFadeDuration, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterHueRotate, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterResampling, Value<RasterResampling>.testConstantValue())
           XCTAssertEqual(layer.rasterSaturation, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }
}

// End of generated file
