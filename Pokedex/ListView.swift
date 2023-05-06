import SwiftUI

@MainActor
final class ListViewModel: ObservableObject {
  @Published var pokemonList: [Pokemon] = []
  @Published var showFavourites = false {
    didSet {
      didSetFavourite()
    }
  }

  @Published var searchText = "" {
    didSet {
      pokemonList = pokemonList.filter { $0.name.hasPrefix(searchText.lowercased()) }
    }
  }

  // Dependencies
  private var pokemonAPI: API.Pokemon?

  private var favouritesList: [Pokemon] = []
  private var allPokemonList: [Pokemon] = []

  private func didSetFavourite() {
    pokemonList = (showFavourites ? favouritesList : allPokemonList)
  }

  func onAppear(
    pokemonAPI: API.Pokemon
  ) {
    self.pokemonAPI = pokemonAPI

    var favouritePokemonsSet: Set<Pokemon> = Set<Pokemon>()
    do {
      favouritePokemonsSet = try JSONDecoder().decode(
        Set<Pokemon>.self,
        from: Current.dataManager.load(URL.pokemons)
      )
    } catch {

    }

    favouritesList = Array(favouritePokemonsSet)

    didSetFavourite()

    // Run Get List only on first Appearance
    if allPokemonList.isEmpty {
      Task {
        do {
          allPokemonList = try await pokemonAPI.getList()
          // Initialize list with all pokemon from api.
          pokemonList = allPokemonList
        } catch {
          print("\(error)")
        }
      }
    }
  }
}

extension URL {
  fileprivate static let pokemons = Self.documentsDirectory.appending(component: "pokemons.json")
}

struct ListView: View {
  @Environment(\.pokemonAPI) var pokemonAPI: API.Pokemon

  @StateObject var viewModel = ListViewModel()

  var body: some View {
    NavigationStack {
      List($viewModel.pokemonList) { $pokemon in
        NavigationLink {
          DetailsView(pokemon: pokemon)
        } label: {
          RowView(pokemon: $pokemon.wrappedValue)
        }
      }
      .navigationTitle("app_title_key")
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(.insetGrouped)
      .searchable(text: $viewModel.searchText, prompt: Text("search_key"))
      .animation(Animation.easeInOut, value: viewModel.pokemonList)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Toggle("favourites_key", isOn: $viewModel.showFavourites)
        }
      }
      .onAppear {
        viewModel.onAppear(
          pokemonAPI: pokemonAPI
        )
      }
    }
  }
}

struct PokemonListView_Previews: PreviewProvider {
  static var previewObjects = API.Pokemon.PagedResponse(results: [
    Pokemon(
      id: 11,
      name: "Hello",
      image: ""
    ),
    Pokemon(
      id: 42,
      name: "Hello2",
      image: ""
    ),
    Pokemon(
      id: 43,
      name: "Hello1",
      image: ""
    )
  ])
  
  static var previews: some View {
    ListView()
    // TODO: we need to somehow pass both api calls here,
    // not only the get List.
      .environment(\.pokemonAPI, .preview(objects: previewObjects))
  }
}