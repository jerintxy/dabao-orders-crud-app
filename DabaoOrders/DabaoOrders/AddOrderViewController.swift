//
//  AddOrderViewController.swift
//  DabaoOrders
//
//  Created by Jerin Tan on 26/10/26.
//

/*
1. Form: write the protocol
2. Form: add a `weak var delegate`
3. Form: call the delegate when Save is tapped
 
4. List: conform to the protocol
5. List: implement its method
6. List: set itself as the delegate before showing the form
*/

// Step 1 to 3

import UIKit

protocol AddOrderDelegate: AnyObject {
    func didAdd(_ order: Order)
}

final class AddOrderViewController: UIViewController {
    weak var delegate: AddOrderDelegate?
    private let dishField = UITextField()
    private let stepper = UIStepper()
    
    private let drinkSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false // Defaults to food/false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let drinkLabel: UILabel = {
        let label = UILabel()
        label.text = "Is this a drink?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New order"
        dishField.placeholder = "Dish"
        dishField.borderStyle = .roundedRect
        stepper.minimumValue = 1
        stepper.value = 1
        
        let stack = UIStackView(arrangedSubviews: [dishField, stepper, drinkLabel, drinkSwitch])
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .save, primaryAction: UIAction { [weak self] _ in self?.saveTapped() })
    }
    
    private func saveTapped() {
        // validate that the text field is not empty
        guard let dish = dishField.text, !dish.isEmpty else { return }

        let newOrder = Order(dish: dish, quantity: Int(stepper.value), isDrink: drinkSwitch.isOn)

        // pass the completed order to your delegate
        delegate?.didAdd(newOrder)

        dismiss(animated: true)
    }
}

