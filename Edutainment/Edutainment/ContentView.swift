//
//  ContentView.swift
//  Edutainment
//
//  Created by Julia Martcenko on 28/01/2025.
//

import SwiftUI

struct ContentView: View {
	@State private var tableLevel = 0 // add 2
	@State private var numberOfQwestions = 5
	@State private var answer: Int?

	@State private var examples: [String] = []
	@State private var rootExample: String?
	@State private var rightAnswer: Int?

	let questionsNumbers = [5, 10, 20]

    var body: some View {
		NavigationStack {
			Form {
				Picker("Levels of table up to:", selection: $tableLevel) {
					ForEach(2..<13) {
						Text("\($0)")
					}
				}

				Section("Number of questions you want to answer:") {
					Picker("Questions numbers", selection: $numberOfQwestions) {
						ForEach(questionsNumbers, id: \.self) {
							Text("\($0)")
						}
					}
					.pickerStyle(.segmented)
				}
				Text(rootExample ?? "")
				Section {
					TextField("Solution", value: $answer, format: .number)
						.keyboardType(.decimalPad)
				}
			}
		}
		.onAppear() {
			startGame()
		}
    }

	func startGame() {
		// 1. Find the URL for start.txt in our app bundle
		if let tablesURL = Bundle.main.url(forResource: "tables", withExtension: "txt") {
			// 2. Load start.txt into a string
			if let startWords = try? String(contentsOf: tablesURL, encoding: .ascii) {
				// 3. Split the string up into an array of strings, splitting on line breaks
				let allExamples = startWords.components(separatedBy: "\n")

				// Save only examles needed for the game
				for example in allExamples {
					if Int(example.components(separatedBy: " ").first?.trimmingCharacters(in: .whitespaces) ?? "13") ?? 13 <= tableLevel + 2 {
						examples.append(example)
//						examples[0] = example
						print ("\(examples)")
						print ("\(example)")
					} else {
						break
					}
				}

				// 4. Pick one random word, or use "silkworm" as a sensible default
				let randomExample = examples.randomElement() ?? "13 x 0"
//				let randomExample = allExamples.randomElement() ?? "13 x 0"

				rootExample = randomExample.components(separatedBy: "=").first ?? "2 x 0"
				rightAnswer = Int(randomExample.components(separatedBy: " ").last ?? "0")
				// If we are here everything has worked, so we can exit
				return
			}
		}

		// If were are *here* then there was a problem – trigger a crash and report the error
		fatalError("Could not load start.txt from bundle.")
	}
}

#Preview {
    ContentView()
}
