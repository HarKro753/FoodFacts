import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct FoodGroup: Identifiable {
    public let id: Int
    public let name: String
    public let icon: String
    public let color: Color
    
    public init(id: Int, name: String, icon: String, color: Color) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
}
