//
//  ChartUIView.swift
//  FIT3178-Final-Project
//
//  Created by Harry Lane on 3/6/2024.
//

import Foundation
import SwiftUI
import Charts

/// Holds the name and amount of a certain category of activity
struct ActivityDataStructure: Identifiable {
    var name: String
    var value: Int
    var id = UUID()
}

/// Chart object for home screen
struct ChartUIView: View{
    var data: [ActivityDataStructure]
    
    var body: some View {
        Chart(data) { category in // loop through each category and add it
            if category.value > 0 {
                SectorMark( // create pie chart
                    angle: .value(
                        Text(verbatim: category.name),
                        category.value
                    ),
                    innerRadius: .ratio(0.5),
                    angularInset: 8
                )
                .foregroundStyle(by: .value("Category", category.name))
                .annotation(position: .overlay) {
                    Text("\(category.value)") // put category on legend and label amount on chart
                }
            }
        }
        .padding()
    }
}

