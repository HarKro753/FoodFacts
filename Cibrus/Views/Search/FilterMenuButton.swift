import AVFoundation
import Env
import Network
import SwiftUI

struct FilterMenuButton: View {
    @Environment(SearchManager.self) private var manager

    var body: some View {
        Menu {
            ForEach(ProductFilter.allCases) { filter in
                Button {
                    manager.toggleFilter(filter)
                } label: {
                    Label {
                        Text(filter.displayName)
                    } icon: {
                        if manager.getActiveFilters().contains(filter) {
                            Image(systemName: "checkmark")
                        }
                        Image(systemName: filter.icon)
                    }
                }
            }

            if !manager.getActiveFilters().isEmpty {
                Divider()

                Button(role: .destructive) {
                    manager.clearFilters()
                } label: {
                    Label("Clear All Filters", systemImage: "xmark.circle.fill")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 22))
                .foregroundStyle(.primary)

        }.menuActionDismissBehavior(.disabled)
    }
}
