CREATE TABLE IF NOT EXISTS users (
  username VARCHAR(22) PRIMARY KEY,
  games_played INT DEFAULT 0,
  best_game INT
);
