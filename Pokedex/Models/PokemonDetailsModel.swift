import Foundation

struct PokemonDetailsModel: Codable, Equatable {
  let height: Int
  let weight: Int
  let moves: [String]
  let types: [String]
  
  enum CodingKeys: CodingKey {
    case height
    case weight
    case moves
    case types
  }
  
  init(
    height: Int,
    weight: Int,
    moves: [String],
    types: [String]
  ) {
    self.height = height
    self.weight = weight
    self.moves = moves
    self.types = types
  }
  
  // MARK: Codable
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    height = try container.decode(Int.self, forKey: .height)
    weight = try container.decode(Int.self, forKey: .weight)

    let moves = try container.decode([Moves].self, forKey: .moves)
    let types = try container.decode([Types].self, forKey: .types)
    
    self.moves = moves.map { $0.move.name }
    self.types = types.map { $0.type.name }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.height, forKey: CodingKeys.height)
    try container.encode(self.weight, forKey: CodingKeys.weight)
    
    let movesArray = moves.map { Moves(move: Moves.Move(name: $0)) }
    let typesArray = types.map { Types(type: Types.Species(name: $0)) }
    
    try container.encode(movesArray, forKey: CodingKeys.moves)
    try container.encode(typesArray, forKey: CodingKeys.types)
  }
  
  // MARK: Structs to Map to and from Backend Models
  struct Moves: Codable {
    let move: Move
    
    struct Move: Codable {
      let name: String
    }
  }
  
  struct Types: Codable {
    let type: Species
    
    struct Species: Codable {
      let name: String
    }
  }
}

extension PokemonDetailsModel {
  static let mock = Self.init(
    height: 3,
    weight: 32,
    moves: [
      "poison-sting",
      "string-shot",
      "bug-bite",
      "electroweb"
    ],
    types: [
      "fire",
      "poison"
    ]
  )
}
