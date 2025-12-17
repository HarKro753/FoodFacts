import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
public struct Category: Identifiable {
    public let id: Int
    public let name: String
    public let icon: String
    public let color: Color
    public let imageName: String?
}
