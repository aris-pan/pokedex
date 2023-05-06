import Foundation

fileprivate enum APIError: Error {
  case unexpectedResponse
}

struct PokemonListModel: Codable {
  let count: Int?
  let next: URL?
  let previous: URL?
  let results: [Pokemon]

  init(results: [Pokemon]) {
    self.count = nil
    self.next = nil
    self.previous = nil
    self.results = results
  }

  struct Pokemon: Codable, Hashable, Identifiable {
    typealias Id = Tagged<Pokemon, Int>

    var id: Id
    let name: String
    let image: URL?

    enum CodingKeys: String, CodingKey {
      case name
      case url
    }

    init(id: Id, name: String, image: String) {
      self.id = id
      self.name = name
      self.image = URL(string: image)
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(String.self, forKey: .name)
      let url = try container.decodeIfPresent(String.self, forKey: .url)

      guard let pokemonID = url?.components(separatedBy: "/")[safe: 6],
            let intID = Int(pokemonID) else {
        throw APIError.unexpectedResponse
      }

      self.id = Id(rawValue: intID)
      self.image = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonID).png")
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(name, forKey: .name)
      try container.encode("https://pokeapi.co/api/v2/pokemon/\(id.rawValue)", forKey: .url)
    }
  }
}

extension PokemonListModel {
  static let mock = Self.init(results: [
    .init(id: 1, name: "Pikatsu", image: ""),
    .init(id: 2, name: "Pikatsu 2", image: ""),
    .init(id: 3, name: "Pikatsu 3", image: ""),
    .init(id: 4, name: "Pikatsu 5", image: "")
  ])
}
