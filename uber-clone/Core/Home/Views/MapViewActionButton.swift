//
//  MapViewActionButton.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/25/24.
//

import SwiftUI

struct MapViewActionButton: View {
    var body: some View {
        Button {
            
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .foregroundStyle(.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MapViewActionButton()
}
