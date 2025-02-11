//
//  ContentView.swift
//  Edutainment
//
//  Created by Julia Martcenko on 28/01/2025.
//

import SwiftUI

struct GameView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var isShowingPopover = false

	@State var examples: [String] = []
	@State var rootExample: String?
	@State var rightAnswer: Int?

	let numberOfQuestions: Int

	@State var answer: Int?
	@State var score: Int = 0

	var body: some View {
		VStack(alignment: .center) {
			Text(rootExample ?? "")
			TextField("Solution", value: $answer, format: .number)
				.keyboardType(.decimalPad)
				.onSubmit {
					if validateAnswer() {
						score += 1
					}
					answer = nil
					setNewLevel()
				}
				.padding()
				.frame(width: 250)
			Text("Score: \(score)/\(numberOfQuestions)")
			Spacer()
			HStack {
				Spacer()
				Button("New Game") {
					dismiss()
				}
				.frame(width: 150, height: 150)
				.background(.red)
				.clipShape(.circle)
				.foregroundStyle(.white)

				Spacer()
			}
		}
		.font(.largeTitle)
		.onAppear() {
			assignTheValue()
		}
		.popover(
			isPresented: $isShowingPopover, arrowEdge: .bottom
		) {
			VStack {
				Text("Game Over")
					.padding()
				Text("Your score is \(score)/\(numberOfQuestions)")
				Button("New game") {
					dismiss()
				}
					.frame(width: 150, height: 100)
					.background(.red)
					.clipShape(.rect)
					.cornerRadius(20)
					.foregroundStyle(.white)
			}
			.font(.largeTitle)
			.presentationBackground(.yellow)

		}
		.background(Color.yellow)
	}

	func validateAnswer() -> Bool {
		answer == rightAnswer
	}

	func setNewLevel() {
		answer = nil
		examples.removeFirst()
		assignTheValue()
		if examples.isEmpty {
			isShowingPopover = true
		}
	}

	func assignTheValue() {

		guard let firstExample = examples.first else {
			return
		}

		rootExample = firstExample.components(separatedBy: "=").first ?? "13 x 0"
		rightAnswer = Int(firstExample.components(separatedBy: " ").last ?? "0")
	}
}

struct ContentView: View {
	@State private var tableLevel = 0 // add 2
	@State private var numberOfQuestions = 5
	@State private var answer: Int?
	@State private var score: Int = 0

	@State private var allExamples: [String] = []
	@State private var examples: [String] = []
	@State private var rootExample: String?
	@State private var rightAnswer: Int?

	let questionsNumbers = [5, 10, 20]

	@State private var isShoingGameView = false

    var body: some View {
		NavigationStack {
			VStack {
				Spacer()
				Form {
					Picker("Levels of table up to:", selection: $tableLevel) {
						ForEach(2..<13) {
							Text("\($0)")
						}
					}

					Section("Number of questions you want to answer:") {
						Picker("Questions numbers", selection: $numberOfQuestions) {
							ForEach(questionsNumbers, id: \.self) {
								Text("\($0)")
							}
						}
						.pickerStyle(.segmented)
					}

				}
				.scrollContentBackground(.hidden)
				VStack {
					Button("New Game") {
												examples = []
												rootExample = nil
												rightAnswer = nil
												answer = nil
												score = 0
												startGame()
						isShoingGameView = true
					}
					.frame(width: 150, height: 150)
					.background(.red)
					.clipShape(.circle)
					.foregroundStyle(.white)
				}

			}
			.navigationDestination(isPresented: $isShoingGameView) {
				GameView(examples: examples, rootExample: rootExample, rightAnswer: rightAnswer, numberOfQuestions: numberOfQuestions)
					.navigationBarBackButtonHidden(true)
			}
			.background(Color.yellow)
			.navigationTitle("Settings")
		}
		.onAppear() {
			launchApp()
		}
    }

	func launchApp() {
		// 1. Find the URL for start.txt in our app bundle
		if let tablesURL = Bundle.main.url(forResource: "tables", withExtension: "txt") {
			// 2. Load start.txt into a string
			if let startWords = try? String(contentsOf: tablesURL, encoding: .ascii) {
				// 3. Split the string up into an array of strings, splitting on line breaks
				allExamples = startWords.components(separatedBy: "\n")

				// If we are here everything has worked, so we can exit
				return
			}
		}
		fatalError("Could not load start.txt from bundle.")
	}

	func startGame() {
		examples = []
		rootExample = nil
		rightAnswer = nil
		answer = nil
		score = 0

		var sortedExamples = [String]()
		// Save only examles needed for the game
		for example in allExamples {
			if Int(example.components(separatedBy: " ").first?.trimmingCharacters(in: .whitespaces) ?? "13") ?? 13 <= tableLevel + 2 {
				sortedExamples.append(example)
			} else {
				break
			}
		}

		// create random array from questions
		while examples.count < numberOfQuestions {
			let element = sortedExamples.randomElement()
			guard let element = element else {
				break
			}
			examples.append(element)
		}
	}
}

#Preview {
    ContentView()
}
