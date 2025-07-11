#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generar número secreto
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT TRIM(games_played), TRIM(best_game) FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
else
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Comenzar juego
echo "Guess the secret number between 1 and 1000:"
while true; do
  read GUESS
  ((GUESS_COUNT++))

  # Validar entero
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Actualizar juegos
    $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'"

    # Actualizar mejor intento si aplica
    CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    if [[ -z $CURRENT_BEST || $GUESS_COUNT -lt $CURRENT_BEST ]]; then
      $PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username='$USERNAME'"
    fi

    break
  fi
done