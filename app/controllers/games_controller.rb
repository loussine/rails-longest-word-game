class GamesController < ApplicationController

  require 'net/http'

  def new
    alphabet = ("A".."Z").to_a
    @letters = alphabet.sample(10).shuffle!
    session[:letters] = @letters
    session[:score] ||= 0  # Initialise le score s'il n'est pas encore défini dans la session.
  end

  def score
    word = params[:longest_word_founded].to_s.strip
    # raise
    # Récupérer les lettres de la grille de la session
    # (avoir stocké les lettres lors de la création de la grille)
    letters = session[:letters]

    # Scénario 1: Le mot ne peut pas être créé à partir de la grille d’origine.
    unless valid_word?(word, letters)
      @result_message = "Sorry but&nbsp;<strong>#{word}</strong>&nbsp;can't be built out of #{session[:letters].join(', ')}"
    else
      # Scénario 2: Le mot est valide d'après la grille, mais ce n'est pas un mot anglais valide.
      if english_word?(word)
        @result_message = "<strong>Congratulations!</strong>&nbsp;<strong>#{word}</strong>&nbsp;is a valid English word!"
        # Ajouter ici la logique pour incrémenter le score.
        score_for_word = word.length
        session[:score] += score_for_word
        session[:last_word_score] = score_for_word  # Optionnel : Stocke le score du dernier mot
      else
        # Scénario 3: Le mot est valide d'après la grille et est un mot anglais valide.
        @result_message = "Sorry but&nbsp;<strong>#{word}</strong>&nbsp;does not seem to be a valid English word..."
      end
    end
  end

  def valid_word?(word, letters)
    word_array = word.upcase.chars
    # Vérifier que chaque lettre du word_array est incluse dans l'array letters
    word_array.all? { |letter| letters.include?(letter) }
  end

  def english_word?(word)
    # Vérifier si le mot est un mot anglais valide en utilisant l'API
    uri = URI("https://wagon-dictionary.herokuapp.com/#{word}")
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)
    result['found']
  end
end
