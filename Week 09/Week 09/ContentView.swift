//
//  ContentView.swift
//  Week 09
//
//  Created by MacBook Pro on 10/11/23.
//

import SwiftUI

struct Card: Codable {
    let object: String
    let total_cards: Int
    let has_more: Bool
    let data: [CardData]
}

struct CardData: Codable {
    let object: String?
    let id: String?
    let oracle_id: String?
    let multiverse_ids: [Int]?
    let mtgo_id: Int?
    let arena_id: Int?
    let tcgplayer_id: Int?
    let cardmarket_id: Int?
    let name: String?
    let lang: String?
    let released_at: String?
    let uri: String?
    let scryfall_uri: String?
    let layout: String?
    let highres_image: Bool?
    let image_status: String?
    let image_uris: ImageURIs?
    let mana_cost: String?
    let cmc: Double?
    let type_line: String?
    let oracle_text: String?
    let colors: [String]?
    let color_identity: [String]?
    let keywords: [String]?
    let legalities: Legalities?
    let games: [String]?
    let reserved: Bool?
    let foil: Bool?
    let nonfoil: Bool?
    let finishes: [String]?
    let oversized: Bool?
    let promo: Bool?
    let reprint: Bool?
    let variation: Bool?
    let set_id: String?
    let set: String?
    let set_name: String?
    let set_type: String?
    let set_uri: String?
    let set_search_uri: String?
    let scryfall_set_uri: String?
    let rulings_uri: String?
    let prints_search_uri: String?
    let collector_number: String?
    let digital: Bool?
    let rarity: String?
    let flavor_text: String?
    let card_back_id: String?
    let artist: String?
    let artist_ids: [String]?
    let illustration_id: String?
    let border_color: String?
    let frame: String?
    let frame_effects: [String]?
    let security_stamp: String?
    let full_art: Bool?
    let textless: Bool?
    let booster: Bool?
    let story_spotlight: Bool?
    let promo_types: [String]?
    let edhrec_rank: Int?
    let penny_rank: Int?
    let prices: Prices?
    let related_uris: RelatedURIs?
    let purchase_uris: PurchaseURIs?
}

struct ImageURIs: Codable {
    let small: String?
    let normal: String?
    let large: String?
    let png: String?
    let art_crop: String?
    let border_crop: String?
}

struct Legalities: Codable {
    let standard: String?
    let future: String?
    let historic: String?
    let gladiator: String?
    let pioneer: String?
    let explorer: String?
    let modern: String?
    let legacy: String?
    let pauper: String?
    let vintage: String?
    let penny: String?
    let commander: String?
    let oathbreaker: String?
    let brawl: String?
    let historicbrawl: String?
    let alchemy: String?
    let paupercommander: String?
    let duel: String?
    let oldschool: String?
    let premodern: String?
    let predh: String?
}

struct Prices: Codable {
    let usd: String?
    let usd_foil: String?
    let usd_etched: String?
    let eur: String?
    let eur_foil: String?
    let tix: String?
}

struct RelatedURIs: Codable {
    let gatherer: String?
    let tcgplayer_infinite_articles: String?
    let tcgplayer_infinite_decks: String?
    let edhrec: String?
}

struct PurchaseURIs: Codable {
    let tcgplayer: String?
    let cardmarket: String?
    let cardhoarder: String?
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var cards: [CardData] = []
    @State private var sortOption: SortOption = .color

    enum SortOption {
        case color
        case alphabet
    }

    var sortedCards: [CardData] {
        switch sortOption {
        case .color:
            return cards
        case .alphabet:
            return cards.sorted { card1, card2 in
                guard let name1 = card1.name, let name2 = card2.name else {
                    return false
                }
                return name1.localizedStandardCompare(name2) == .orderedAscending
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()

                Picker("Sort By", selection: $sortOption) {
                    Text("Color").tag(SortOption.color)
                    Text("Alphabet").tag(SortOption.alphabet)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    LazyVGrid(columns: createGrid(), spacing: 16) {
                        ForEach(sortedCards.filter { card in
                            searchText.isEmpty || (card.name ?? "").localizedCaseInsensitiveContains(searchText)
                        }, id: \.name) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardView(card: card)
                            }
                        }
                    }
                    .padding(16)
                }

                Spacer()
            }
            .navigationTitle("Search Cards")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let url = Bundle.main.url(forResource: "WOT-Scryfall", withExtension: "json") {
                    do {
                        let data = try Data(contentsOf: url)
                        let decoder = JSONDecoder()
                        let card = try decoder.decode(Card.self, from: data)
                        self.cards = card.data
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
        }
    }

    private func createGrid() -> [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 4)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search ", text: $text)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .autocapitalization(.none)
    }
}

struct CardView: View {
    let card: CardData

    var body: some View {
        AsyncImage(url: URL(string: card.image_uris?.normal ?? "")!) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct CardDetailView: View {
    let card: CardData
    @State private var displayOption: DisplayOption = .oracleText

    enum DisplayOption {
        case oracleText
        case legalities
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: card.image_uris?.large ?? "")!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .padding()

                if let name = card.name {
                    Text(name)
                        .font(.title)
                        .padding()
                }

                Picker("Display Option", selection: $displayOption) {
                    Text("Oracle Text").tag(DisplayOption.oracleText)
                    Text("Legalities").tag(DisplayOption.legalities)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if displayOption == .oracleText, let oracleText = card.oracle_text {
                    Text(oracleText)
                        .font(.body)
                        .padding()
                } else if displayOption == .legalities, let legalities = card.legalities?.toDictionary() {
                    ForEach(Array(legalities.keys).sorted(), id: \.self) { key in
                        if let value = legalities[key] {
                            HStack {
                                Text(key)
                                    .font(.headline)
                                    .padding()

                                Text(value)
                                    .font(.headline)
                                    .padding()
                                    .background(value == "legal" ? Color.green : Color.gray)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .cornerRadius(4)

                                Spacer()
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension Legalities {
    func toDictionary() -> [String: String] {
        return Mirror(reflecting: self).children.reduce(into: [String: String]()) { dict, child in
            if let key = child.label {
                dict[key] = child.value as? String
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Dictionary where Key == String {
    var dictionary: [(String, Value?)] {
        map { ($0, $1) }
    }
}
