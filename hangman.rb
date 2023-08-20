require 'csv'
require 'json'

content = File.readlines('google-10000-english-no-swears.txt')
WORDS = []
content.each do|line|
    WORDS.append(line.chomp)
end
WORDS

@guess = []
@tries = 6

def random_word
    WORDS.sample
end

def isalpha(char)
    char.upcase != char.downcase
end
  
def get_guess
    c = '1'
    until isalpha(c)
        puts 'Enter your Guess or enter \'save\' to save'
        c = gets.chomp
    end
    c.downcase
end

# def play(word)
#     word_completion = "_" * word.length
#     guessed = false
#     guessed_letters = []
#     guessed_words = []
#     tries = 6
#     print("Let's play Hangman!")
#     print(display_hangman(tries))
#     print(word_completion)
#     print("\n")
#     while not guessed and tries > 0
#         puts("Please guess a letter or word")
#         guess = gets.upcase.chomp
#         if guess.length == 1 and isalpha(guess)
#             if guessed_letters.include?(guess)
#                 print("You already guessed the letter #{guess} ")
#             elsif word.include?(guess)
#                 print(guess, "is not in the word.")
#                 tries -= 1
#                 guessed_letters.append(guess)
#             else
#                 print("Good job,", guess, " is in the word!")
#                 guessed_letters.append(guess)
#                 word_as_list = word_completion.split("")
#                 indices = []
#                 word.length.times {|i| indices << i if word[i,1] == guess}
#                 for index in indices
#                     word_as_list[index] = guess
#                 end
#                 word_completion = word_as_list.join("")
#                 if  !word_completion.include?("_")
#                     guessed = True
#                 end
#             end
#         elsif guess.length == word.length and isalpha(guess)
#             if guessed_words.include?(word)
#                 print("You already guessed the word", guess)
#             elsif guess != word
#                 print(guess, "is not the word.")
#                 tries -= 1
#                 guessed_words.append(guess)
#             else
#                 guessed = true
#                 word_completion = word
#             end
#         else
#             puts "Not a valid guess."
#         puts "#{display_hangman(tries)}"
#         puts "#{word_completion}"
#         end
#     end
#     if guessed
#         print("Congrats, you guessed the word! You win!")
#     else
#         print("Sorry, you ran out of tries. The word was " + word + ". Maybe next time!")
#     end
# end

def play(word,guessed_letters=[],guessed_words=[],tries = 6)
    guess = '1'
    guessed = false
    string = "_" * word.length
    string.split('').each_with_index{|ch,id| string[id] = word[id] if guessed_letters.include?(word[id])}
    until ((guessed) or (tries == 0))
        puts string.split('').join(' ')
        guess = get_guess
        save_game(word,guessed_letters,guessed_words,tries) if guess == 'save'
        puts guess
        if guess.length == 1
            if guessed_letters.include?(guess)
                puts "#{guess} already in #{guessed_letters}"
                guess = get_guess
                save_game(word,guessed_letters,guessed_words,tries) if guess == 'save'
            else
                guessed_letters.append(guess) 
            end
            tries -= 1 if !word.split('').uniq.include?(guess)
            guessed = word.split('').uniq.all?{|ch| guessed_letters.include?(ch)}
            string.split('').each_with_index{|ch,id| string[id] = word[id] if guessed_letters.include?(word[id])}
        else
            if guessed_words.include?(guess)
                puts "#{guess} already in #{guessed_words}"
                guess = get_guess
                save_game(word,guessed_letters,guessed_words,tries) if guess == 'save'
            else
                guessed_letters.append(guess)
                tries -= 1
            end
            guessed = guessed_words.include?(word)
        end
    end
end

def display_hangman(tries)
    stages = [  # final state: head, torso, both arms, and both legs
                """
                   --------
                   |      |
                   |      O
                   |     \\|/
                   |      |
                   |     / \\
                   -
                """,
                # head, torso, both arms, and one leg
                """
                   --------
                   |      |
                   |      O
                   |     \\|/
                   |      |
                   |     / 
                   -
                """,
                # head, torso, and both arms
                """
                   --------
                   |      |
                   |      O
                   |     \\|/
                   |      |
                   |      
                   -
                """,
                # head, torso, and one arm
                """
                   --------
                   |      |
                   |      O
                   |     \\|
                   |      |
                   |     
                   -
                """,
                # head and torso
                """
                   --------
                   |      |
                   |      O
                   |      |
                   |      |
                   |     
                   -
                """,
                # head
                """
                   --------
                   |      |
                   |      O
                   |    
                   |      
                   |     
                   -
                """,
                # initial empty state
                """
                   --------
                   |      |
                   |      
                   |    
                   |      
                   |     
                   -
                """
    ]
    return stages[tries]
end


def save_game(word,guessed_letters,guessed_words,tries)
    CSV.open("myfile.csv","a") do |csv|
        csv << [word,guessed_letters,guessed_words,tries]
    end
    exit
end

def load_game
    content = CSV.open('myfile.csv').each.to_a
    puts "Select the game to load 1-#{content.length}"
    row = gets.chomp.to_i
    content[row]
end


puts 'Want to play new game(0) or load a previous save(1)'
c = gets.chomp.to_i
if c == 1
    content = load_game
    play(content[0],JSON.parse(content[1]),JSON.parse(content[2]),content[3].to_i)
else
    word = random_word
    p word
    play(word)
end



puts("Play Again? (Y/N)")
while gets.upcase.chomp == "Y"
    word = random_word
    p word
    play(word)
end