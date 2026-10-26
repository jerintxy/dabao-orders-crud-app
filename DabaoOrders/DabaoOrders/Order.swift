//
//  Order.swift
//  DabaoOrders
//
//  Created by Jerin Tan on 26/10/26.
//

/*
 
- Hashable, so the diffable data source can tell orders apart
- Codable, so we can turn orders into JSON later
- nonisolated, so those two conformances aren't stuck on the main actor (the error from CRUD Part 2)

*/

import Foundation

nonisolated struct Order: Hashable, Codable {
    var id = UUID()
    var dish: String
    var quantity: Int
    var isDrink: Bool
    
    
}


