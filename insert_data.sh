#! /bin/bash

# Check whether to use the test database or the main database
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear any previous data in the tables
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY;")"

# Read games.csv file and insert data into the database
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Skip the header row
  if [[ $year != "year" ]]
  then
    # Insert winner team into the teams table if not already exists
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    if [[ -z $winner_id ]]
    then
      # Insert winner team
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$winner');")"
      # Get the new winner_id
      winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    fi

    # Insert opponent team into the teams table if not already exists
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
    if [[ -z $opponent_id ]]
    then
      # Insert opponent team
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$opponent');")"
      # Get the new opponent_id
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
    fi

    # Insert the game data into the games table
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                     VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")"
  fi
done
