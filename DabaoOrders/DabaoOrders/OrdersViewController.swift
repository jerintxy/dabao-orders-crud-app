//
//  ViewController.swift
//  DabaoOrders
//
//  Created by Jerin Tan on 26/10/26.
//

import UIKit

//nonisolated enum Section { case main }
nonisolated enum Section { case drinks, food }


/*
1. Form: write the protocol
2. Form: add a `weak var delegate`
3. Form: call the delegate when Save is tapped
 
4. List: conform to the protocol
5. List: implement its method
6. List: set itself as the delegate before showing the form
*/

// Step 4 to 6



class OrderDiffableDataSource: UITableViewDiffableDataSource<Section, Order> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // fetch the section type based on the index position
        let sectionKind = snapshot().sectionIdentifiers[section]
        
        switch sectionKind {
        case .drinks: return "Drinks"
        case .food:   return "Food"
        }
    }
}



class OrdersViewController: UIViewController, AddOrderDelegate {
    
    
    private let tableView = UITableView()
    
    private var orders: [Order] = [
        Order(dish: "Chicken rice", quantity: 1, isDrink: false),
        Order(dish: "Teh peng", quantity: 2, isDrink: true),
        Order(dish: "Roti prata", quantity: 3, isDrink: false)
    ]

    //private var dataSource: UITableViewDiffableDataSource<Section, Order>!
    private var dataSource: OrderDiffableDataSource!
    
    // Save and load as JSON
    private let fileURL = URL.documentsDirectory.appending(path: "orders.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Orders"
        
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        dataSource = OrderDiffableDataSource(tableView: tableView) { tableView, indexPath, order in
          
        //dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, order in
            // dequeue the cell (returns a non-optional UITableViewCell)
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            
            // set text values
            content.text = order.dish
            content.secondaryText = "Qty: \(order.quantity)"
            
            // push the configuration back into the cell
            cell.contentConfiguration = content
            
            return cell
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add, primaryAction: UIAction { [weak self] _ in self?.showAdd()}
        )
        
        load()
        applySnapshot()
        
        
        print(fileURL)
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Order>()
        snapshot.appendSections([.drinks, .food])
        
        // separate array into groups and target individual sections
        let drinkOrders = orders.filter { $0.isDrink }
        let foodOrders = orders.filter { !$0.isDrink }
        
        snapshot.appendItems(drinkOrders, toSection: .drinks)
        snapshot.appendItems(foodOrders, toSection: .food)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showAdd() {
        let addVC = AddOrderViewController()
        addVC.delegate = self
        present(UINavigationController(rootViewController: addVC), animated: true)
    }
    
    func didAdd(_ order: Order) {
        orders.append(order)
        save()
        applySnapshot()
    }

    // Save and load as JSON
    //    - In `viewDidLoad`, call `load()` just *before* `applySnapshot()`
    //    - In `didAdd`, call `save()` just after `orders.append(order)`
    private func save() {
        do {
            //let data = try JSONEncoder().encode(orders)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(orders)
            
            try data.write(to: fileURL)
        } catch {
            print("Save faild: \(error)")
        }
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
                let saved = try? JSONDecoder().decode([Order].self, from: data) else { return }
        
        orders = saved
    }
    
    
    
    func updateQuantity(of order: Order, to newQuantity: Int) {
        // 1. Find the order in the array by matching the dish name and section type
        if let index = orders.firstIndex(where: { $0.dish == order.dish && $0.isDrink == order.isDrink }) {
            
            // 2. Change the quantity value
            orders[index].quantity = newQuantity
            
            // 3. Save the new array to disk
            save()
            
            // 4. Force diffable to recalculate the whole screen
            applySnapshot()
        }
    }

    
    
}

extension OrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
//        Find the order with dataSource.itemIdentifier(for: indexPath), not orders[indexPath.row],
//        because once you have more than one section, row numbers no longer match your array.
//        Remove it from orders,
//        save, and
//        apply a snapshot.
        
        // find the correct order item safely
        guard let orderToDelete = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        // create the delete contextual action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            self.orders.removeAll { $0.id == orderToDelete.id }
            
            self.save()

            self.applySnapshot()
            
            // signal that the swipe action was completed successfully
            completionHandler(true)
        }
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the row immediately so it doesn't stay gray
        tableView.deselectRow(at: indexPath, animated: true)
        
        // find the tapped order using diffable data source
        guard let order = dataSource.itemIdentifier(for: indexPath) else { return }
        
        
        let nextQuantity = order.quantity >= 5 ? 1 : order.quantity + 1
        
        // fire the update function we created earlier
        updateQuantity(of: order, to: nextQuantity)
    }

}





#Preview {
    OrdersViewController()
}

