//
//  NetworkServiceTests.swift
//  ToDoTests
//
//  Created by DISSEMBILL on 26.05.2025.
//

import XCTest
@testable import ToDo

class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!
    var urlSession: URLSession!
    
    let timeout = 30.0
    
    let mockData = """
    {
        "todos": [
            {"id": 1, "todo": "Test todo 1", "completed": false, "userId":68},
            {"id": 2, "todo": "Test todo 2", "completed": true, "userId":68}
        ]
    }
    """.data(using: .utf8)!
    
    override func setUp() {
        super.setUp()
        
        // Настройка моковой URLSession
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        
        sut = NetworkService()
        sut.session = urlSession
    }
    
    override func tearDown() {
        sut = nil
        urlSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchTodosSuccess() {
        // Arrange
        let expectation = self.expectation(description: "Fetch todos success")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, self.mockData)
        }
        
        // Act
        sut.fetchTodos { result in
            // Assert
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 2)
                XCTAssertEqual(todos[0].title, "Test todo 1")
                XCTAssertEqual(todos[1].title, "Test todo 2")
                XCTAssertFalse(todos[0].isCompleted)
                XCTAssertTrue(todos[1].isCompleted)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFetchTodosNoDataError() {
        // Arrange
        let expectation = self.expectation(description: "No data error")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data()) // Пустые данные
        }
        
        // Act
        sut.fetchTodos { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkError)
                if case NetworkError.noData = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected noData error")
                }
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFetchTodosNetworkError() {
        // Arrange
        let expectation = self.expectation(description: "Network error")
        let mockError = NSError(domain: "test", code: 500, userInfo: nil)
        
        MockURLProtocol.requestHandler = { request in
            throw mockError
        }
        
        // Act
        sut.fetchTodos { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, mockError.code)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFetchTodosDecodingError() {
        // Arrange
        let expectation = self.expectation(description: "Decoding error")
        let invalidData = """
        {
            "wrong_key": [
                {"invalid": "data"}
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidData)
        }
        
        // Act
        sut.fetchTodos { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error is DecodingError)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func testFetchTodosCompletesOnBackgroundThread() {
        // Arrange
        let expectation = self.expectation(description: "Background thread check")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, self.mockData)
        }
        
        // Act
        sut.fetchTodos { _ in
            // Assert
            XCTAssertFalse(Thread.isMainThread, "Completion should not be on main thread")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Mock URLProtocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is unavailable.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
