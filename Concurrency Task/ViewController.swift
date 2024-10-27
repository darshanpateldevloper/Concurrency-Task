//
//  ViewController.swift
//  Concurrency Task

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlet
    
    @IBOutlet weak var lblMessage: UILabel!
    
    
    //MARK: - Custom Methods
    
    func fetchMessageOne(completion: @escaping (Result<String, Error>) -> Void) {
        let delay = Double.random(in: 0...2)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            let message = "Hello"
            DispatchQueue.main.async {
                completion(.success(message))
            }
        }
    }
    
    func fetchMessageTwo(completion: @escaping (Result<String, Error>) -> Void) {
        let delay = Double.random(in: 0...2)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            let message = "World"
            DispatchQueue.main.async {
                completion(.success(message))
            }
        }
        
    }
    
    func loadMessage(completion: @escaping (String) -> Void) {
        // Create a DispatchGroup to coordinate the fetching of both messages
        let group = DispatchGroup()
        
        // Create variables to store the fetched messages
        var message1: String?
        var message2: String?
        
        // Dispatch the fetching of the first message to a background queue
        group.enter()
        DispatchQueue.global().async {
            self.fetchMessageOne { result in
                defer { group.leave() }
                
                switch result {
                case .success(let message):
                    message1 = message
                case .failure:
                    // If fetching the first message fails, we can immediately complete with a timeout error
                    DispatchQueue.main.async {
                        completion("Unable to load message - Time out exceeded")
                    }
                }
            }
        }
        
        // Dispatch the fetching of the second message to a background queue
        group.enter()
        DispatchQueue.global().async {
            self.fetchMessageTwo { result in
                defer { group.leave() }
                
                switch result {
                case .success(let message):
                    message2 = message
                case .failure:
                    // If fetching the second message fails, we can immediately complete with a timeout error
                    DispatchQueue.main.async {
                        completion("Unable to load message - Time out exceeded")
                    }
                }
            }
        }
        
        // Wait for both messages to be fetched or a timeout to occur
        group.notify(queue: .main) {
            if let message1 = message1, let message2 = message2 {
                completion("\(message1) \(message2)")
            } else {
                completion("Unable to load message - Time out exceeded")
            }
        }
    }
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.lblMessage.text = "Start Message Loading...."
        
        loadMessage { message in
            // Update the UI with the loaded message on the main thread
            DispatchQueue.main.async {
                self.lblMessage.text = message
                print(message)
            }
        }
    }
    
}

