class Hangman
	attr_accessor :word_state, :guess

	def initialize
		print "How many human players? "
		@game_type = gets.chomp.to_i

		# Player 1 is ALWAYS hangman
		# Player 2 is ALWAYS guesser
		if @game_type == 0
			player1 = HumanPlayer.new
			player2 = HumanPlayer.new
		elsif @game_type == 1
			print "Who should be the hangman, computer or human? "
			hanger = gets.chomp
			if hanger == "human"
				player1 = HumanPlayer.new
				player2 = ComputerPlayer.new
			else
				player1 == ComputerPlayer.new
				player2 == HumanPlayer.new
			end
		elsif @game_type == 2
			player1 = ComputerPlayer.new
			player2 = ComputerPlayer.new
		end
	end

	def play_game
		until winning_guess?(guess)
	end

	# Sets word_state at beginning of game based on word length
	def update_word_state_initial(length)
		self.word_state = "*" * length
	end

	# Should be passed value from evaluate_guess
	def update_word_state_with_indices(guess, indices)
		indices.each do |i|
			self.word_state[i] = guess
		end
		self.word_state
	end

end

class HumanPlayer
	attr_accessor :word

	# Prompt for a guess
	# Return guess
	def make_guess
		print "Enter a letter or word to guess: "
		gets.chomp
	end

	def set_word_length
		print "How long is your word? "
		gets.chomp.to_i
	end

	# Guess is single letter
	# Ask if letter is in word
	# Return locations or "no" if not included
	def evaluate_guess(guess)
		print "Is #{guess} included in your word?"
		answer = gets.chomp
		if answer == "no"
			return "no"
		elsif answer == "yes"
			print "At what indices? (format '1 2 3') "
		letter_locations = gets.chomp.split(" ").map {|i| i.to_i}
		letter_locations
	end

	# Check winning guess when human is hangman (full word guesses)
	def winning_guess?(guess)
		# Accounts for guess being nil at beginning of game
		return false if guess.nil?

		print "Is #{guess} your word? "
		answer = gets.chomp
		if answer == "yes"
			return true
		else
			return false
		end
	end
end

class ComputerPlayer
	LETTERS = ("a".."z").to_a.map {|x| x.to_sym}

	attr_accessor :word, :dictionary


	# Create dictionary from dictionary.txt file
	def initialize
		@dictionary = File.readlines("dictionary.txt").map {|word| word.strip}
		@dictionary.map! {|word| word.gsub(/[^a-z]/, "")}
	end

	# Should be passed length of word
	def update_dictionary_initial(length)
		self.dictionry = self.dictionary.select do |word|
			word.length == length
		end
	end

	# Update to words matching letters in word_state
	def update_dictionary_with_word_state(word_state)
		self.dictionary = self.dictionary.select do |word|
			word_match = true
			(0..word.length).each do |index|
				word_match = false if word[index] != word_state[index] && word_state[index] != "*"
			end
			word_match
		end
	end

	# Make a guess based on dictionary words
	# Return guess
	def make_guess
		letter_occurrences = []

		if self.dictionary.length > 1
			LETTERS.each do |letter|
				letter_count = 0
				self.dictionary.each do |word|
					letter_count += word.count(letter.to_s)
				end
				letter_occurrences << letter_count
			end
			most_frequent = letter_occurrences.max
			return LETTERS[letter_occurrences.index(most_frequent)].to_s
		else
			return self.dictionary[0]
		end
	end

	# Guess is single letter
	# Check if letter is in word
	# Return locations or "no" if not included
	def evaluate_guess(guess)
		letters = self.word.split(//)
		letter_locations = []
		letters.each_with_index do |letter, index|
			if letter == guess
				letter_locations << index
			end
		end
		if letter_locations.length == 0
			return "no"
		else
			return letter_locations
		end
	end

	# Check winning guess when computer is hangman (full word guesses)
	def winning_guess?(guess)
		# Accounts for guess being nil at beginning of game
		return false if guess.nil?

		if guess == self.word
			return true
		else
			return false
	end
end

# Human is hangman, computer is guesser
# Human thinks of word
# Human inputs word length
# Word state is set to "_" * word.length
# Computer updates dictionary to words of same length
# Computer makes guess
# Human evaluates guess
# Word state is updated to include correct letters
# Computer updates dictionary to words matching current word state
# Computer makes guess
# etc.