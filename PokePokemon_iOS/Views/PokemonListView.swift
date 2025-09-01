//
//  PokemonListView.swift
//  PokePokemon_iOS
//
//  Created by Guilherme Sol on 31/08/2025.
//

import SwiftUI

protocol PokemonListViewable: ObservableObject {
    var items: [PokeListItem] { get }
    var pokeCard: PokemonViewModel? { get set }
    var errorMessage: String? { get set }
    var isLoadingNext: Bool { get }
    var isLoading: Bool { get }
    func load() async
    func loadNext() async
    func refresh() async
    func selected(_ item: PokeListItem) async
}

struct PokemonListView<ViewModel: PokemonListViewable>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var showError = false
    
    var body: some View {
        VStack(alignment: .center){
            titleView
            listView
            if viewModel.isLoading {
                loadingSpinner
            }
        }
        .onAppear{
            Task {
                await viewModel.load()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(item: $viewModel.pokeCard) { item in
            PokemonDetailView<PokemonViewModel>(viewModel: item)
        }
        .onChange(of: viewModel.errorMessage) {  oldValue, newValue in
            showError = newValue != nil
        }
        .alert("Oops!",
               isPresented: $showError,
               presenting: $viewModel.errorMessage) { error in
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: { error in
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    var titleView: some View {
        Text("Pokemons")
            .font(.largeTitle)
    }
    
    var loadingSpinner: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
                .transition(.scale)
                .animation(.easeInOut, value: viewModel.isLoadingNext)
            Spacer()
        }
    }
    
    
    var listView: some View {
        VStack {
            List(viewModel.items) { item in
                HStack(alignment: .center){
                    Spacer()
                    Text(item.name)
                    Spacer()
                }
                .padding(.vertical, 10)
                .onTapGesture {
                    Task {  @MainActor in
                        await viewModel.selected(item)
                    }
                }
                .onAppear{
                    if item.id == viewModel.items.last?.id {
                        Task {
                            await viewModel.loadNext()
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    PokemonListView(viewModel: PokemonListViewModelPreview())
}

private class PokemonListViewModelPreview: PokemonListViewable {
    var pokeCard: PokemonViewModel?
    var items: [PokeListItem] = [
        .init(name: "item 1", url: "any"),
        .init(name: "item 2", url: "any"),
        .init(name: "item 3", url: "any")
    ]
    var errorMessage: String?
    var isLoading: Bool = false
    var isLoadingNext: Bool = false
    
    func load() {
        errorMessage = "errorMessage"
    }
    
    func loadNext() async {
        
    }
    
    func refresh() async {
        
    }
    
    func selected(_ item: PokeListItem) async {
        pokeCard = PokemonViewModel(
            id: 1,
            name: "Pikachu",
            imageUrl: URL(string: "any")!,
            details: [.init(id: "Height", value: "10")]
        )
    }
}
