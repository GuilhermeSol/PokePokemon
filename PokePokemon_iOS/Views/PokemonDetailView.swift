//
//  PokemonDetailView.swift
//  PokePokemon_iOS
//
//  Created by Guilherme Sol on 31/08/2025.
//

import SwiftUI

protocol PokemonViewable {
    var id: Int { get }
    var name: String { get }
    var imageUrl: URL { get }
    var details: [Detail] { get }
}

struct Detail: Identifiable {
    var id: String
    var value: String
}

struct PokemonDetailView<ViewModel: PokemonViewable>: View {
    let viewModel: PokemonViewable

    var body: some View {
        VStack(spacing: 20) {
            titleView
            imageView
            detailsView
        }
        .padding()
    }
    
    var titleView: some View {
        Text(viewModel.name)
            .font(.largeTitle)
    }
    
    var imageView: some View {
        AsyncImage(url: viewModel.imageUrl) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    var detailsView: some View {
        List(viewModel.details) { item in
            HStack(alignment: .center){
                Text(item.id)
                    .font(.subheadline)
                Spacer()
                Text(item.value)
                    .font(.headline)
            }
        }
    }
}

#Preview {    
    PokemonDetailView<PokemonViewModel>(
        viewModel: PokemonViewModel(
            id: 1,
            name: "Pikachu",
            imageUrl: URL(string: "any")!,
            details: [.init(id: "Height", value: "2")]
        )
    )
}
