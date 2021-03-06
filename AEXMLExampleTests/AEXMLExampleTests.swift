//
//  AEXMLExampleTests.swift
//  AEXMLExampleTests
//
//  Created by Marko Tadic on 10/16/14.
//  Copyright (c) 2014 ae. All rights reserved.
//

import UIKit
import XCTest
import AEXMLExample

class AEXMLExampleTests: XCTestCase {
    
    // MARK: - Properties
    
    var exampleXML = AEXMLDocument()
    var plantsXML = AEXMLDocument()
    
    // MARK: - Helper
    
    func readXMLFromFile(filename: String) -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()
        
        // parse xml file
        if let xmlPath = NSBundle.mainBundle().pathForResource(filename, ofType: "xml") {
            if let data = NSData(contentsOfFile: xmlPath) {
                var error: NSError?
                if let xmlDoc = AEXMLDocument(xmlData: data, error: &error) {
                    xmlDocument = xmlDoc
                }
            }
        }
        
        return xmlDocument
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // create some sample xml documents
        exampleXML = readXMLFromFile("example")
        plantsXML = readXMLFromFile("plant_catalog")
    }
    
    override func tearDown() {
        // reset sample xml document
        exampleXML = AEXMLDocument()
        plantsXML = AEXMLDocument()
        
        super.tearDown()
    }
    
    // MARK: - XML Read
    
    func testRootElement() {
        XCTAssertEqual(exampleXML.root.name, "animals", "Should be able to find root element.")
    }
    
    func testParentElement() {
        XCTAssertEqual(exampleXML.root["cats"].parent!.name, "animals", "Should be able to find parent element.")
    }
    
    func testChildrenElements() {
        var count = 0
        for cat in exampleXML.root["cats"].children {
            count++
        }
        XCTAssertEqual(count, 3, "Should be able to iterate children elements")
    }
    
    func testName() {
        let secondChildElementName = exampleXML.root.children[1].name
        XCTAssertEqual(secondChildElementName, "dogs", "Should be able to return element name.")
    }
    
    func testAttributes() {
        let firstCatAttributes = exampleXML.root["cats"]["cat"].attributes
        
        // iterate attributes
        var count = 0
        for attribute in firstCatAttributes {
            count++
        }
        XCTAssertEqual(count, 2, "Should be able to iterate element attributes.")
        
        // get attribute value
        if let firstCatBreed = firstCatAttributes["breed"] as? String {
            XCTAssertEqual(firstCatBreed, "Siberian", "Should be able to return attribute value.")
        } else {
            XCTFail("The first cat should have breed attribute.")
        }
    }
    
    func testStringValue() {
        let firstPlantCommon = plantsXML.root["PLANT"]["COMMON"].stringValue
        XCTAssertEqual(firstPlantCommon, "Bloodroot", "Should be able to return element value as string.")
    }
    
    func testBoolValue() {
        XCTAssertEqual(plantsXML.root["PLANT"]["TRUESTRING"].boolValue, true, "Should be able to cast element value as Bool.")
        XCTAssertEqual(plantsXML.root["PLANT"]["TRUENUMBER"].boolValue, true, "Should be able to cast element value as Bool.")
        XCTAssertEqual(plantsXML.root["PLANT"]["FALSEANYTHINGELSE"].boolValue, false, "Should be able to cast element value as Bool.")
    }
    
    func testIntValue() {
        let firstPlantZone = plantsXML.root["PLANT"]["ZONE"].intValue
        XCTAssertEqual(firstPlantZone, 4, "Should be able to cast element value as Integer.")
    }
    
    func testDoubleValue() {
        let firstPlantPrice = plantsXML.root["PLANT"]["PRICE"].doubleValue
        XCTAssertEqual(firstPlantPrice, 2.44, "Should be able to cast element value as Double.")
    }
    
    func testNotExistingElement() {
        // non-optional
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].name, AEXMLElement.errorElementName, "Should be able to tell you if element does not exist.")
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].stringValue, "element <ducks> not found", "Should be able to tell you which element does not exist.")
        
        // optional
        if let duck = exampleXML.root["ducks"]["duck"].first {
            XCTFail("Should not be able to find ducks here.")
        } else {
            XCTAssert(true)
        }
    }
    
    func testAllElements() {
        var count = 0
        if let cats = exampleXML.root["cats"]["cat"].all {
            for cat in cats {
                count++
            }
        }
        XCTAssertEqual(count, 3, "Should be able to iterate all elements")
    }
    
    func testFirstElement() {
        let catElement = exampleXML.root["cats"]["cat"]
        let firstCatExpectedValue = "Tinna"
        
        // non-optional
        XCTAssertEqual(catElement.stringValue, firstCatExpectedValue, "Should be able to find the first element as non-optional.")
        
        // optional
        if let cat = catElement.first {
            XCTAssertEqual(cat.stringValue, firstCatExpectedValue, "Should be able to find the first element as optional.")
        } else {
            XCTFail("Should be able to find the first element.")
        }
    }
    
    func testLastElement() {
        if let cat = exampleXML.root["cats"]["cat"].last {
            XCTAssertEqual(cat.stringValue, "Caesar", "Should be able to find the last element.")
        } else {
            XCTFail("Should be able to find the last element.")
        }
    }
    
    func testCountElements() {
        let dogsCount = exampleXML.root["dogs"]["dog"].count
        XCTAssertEqual(dogsCount, 4, "Should be able to count elements.")
    }
    
    func testFindWithAttributes() {
        var count = 0
        if let bulls = exampleXML.root["dogs"]["dog"].allWithAttributes(["color" : "white"]) {
            for bull in bulls {
                count++
            }
        }
        XCTAssertEqual(count, 2, "Should be able to iterate elements with given attributes.")
    }
    
    func testCountWithAttributes() {
        let darkGrayDomesticCatsCount = exampleXML.root["cats"]["cat"].countWithAttributes(["breed" : "Domestic", "color" : "darkgray"])
        XCTAssertEqual(darkGrayDomesticCatsCount, 1, "Should be able to count elements with given attributes.")
    }
    
    // MARK: - XML Write
    
    func testAddChild() {
        // TODO: #name
        let ducks = exampleXML.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", stringValue: "Donald")
        ducks.addChild(name: "duck", stringValue: "Daisy")
        ducks.addChild(name: "duck", stringValue: "Scrooge")
        
        let animalsCount = exampleXML.root.children.count
        XCTAssertEqual(animalsCount, 3, "Should be able to add child elements to an element.")
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].last!.stringValue, "Scrooge", "Should be able to iterate ducks now.")
    }
    
    func testAddAttributes() {
        let firstCat = exampleXML.root["cats"]["cat"]
        // add single attribute
        firstCat.addAttribute("funny", value: true)
        // add multiple attributes
        firstCat.addAttributes(["speed" : "fast", "years" : 7])
        
        XCTAssertEqual(firstCat.attributes.count, 5, "Should be able to add attributes to an element.")
        XCTAssertEqual(firstCat.attributes["years"] as Int, 7, "Should be able to get any attribute value now.")
    }
    
    func testXMLString() {
        let newXMLDocument = AEXMLDocument()
        let children = newXMLDocument.addChild(name: "children")
        let child = children.addChild(name: "child", stringValue: "value", attributes: ["attribute" : "attributeValue"])
        
        XCTAssertEqual(newXMLDocument.xmlString, "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n\t<child attribute=\"attributeValue\">value</child>\n</children>", "Should be able to print XML formatted string.")
        XCTAssertEqual(newXMLDocument.xmlStringCompact, "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><children><child attribute=\"attributeValue\">value</child></children>", "Should be able to print compact XML string.")
    }
    
    // MARK: - XML Parse Performance
    
    func testReadXMLPerformance() {
        self.measureBlock() {
            let document = self.readXMLFromFile("plant_catalog")
        }
    }
    
    func testWriteXMLPerformance() {
        self.measureBlock() {
            let xmlString = self.plantsXML.xmlString
        }
    }
    
}
