#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#DATABASE
# DROP DATABASE IF EXISTS worldcup;
# create database worldcup;
# \c worldcup;
# create table teams(team_id SERIAL primary key,name VARCHAR(14) unique not null);
# create table games(game_id SERIAL primary key,year int not null, round varchar(14) not null,winner_id int not null references teams(team_id),
# opponent_id int not null references teams(team_id),winner_goals INT not NULL,opponent_goals INT not null);

echo $($PSQL "TRUNCATE TABLE games,teams")

cat games.csv | while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $winner != 'winner' ]]
  then
    insert_id_winner_team=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'");
    if [[ -z $insert_id_winner_team ]]
    then
      insert_id_winner_team=$($PSQL "INSERT INTO teams(name) VALUES('$winner') RETURNING team_id");
    fi

    insert_id_opponent_team=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'");
    if [[ -z $insert_id_opponent_team ]]
    then
      insert_id_opponent_team=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') RETURNING team_id");
    fi
  fi

  if [[ $year != 'year' ]]
  then
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'");
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'");
    insert_row_to_game_result=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($year,'$round',$winner_id,$opponent_id,$winner_goals,$opponent_goals)");
    if [[ -z $insert_row_to_game_result ]]
    then
      echo Inserted in games $insert_row_to_game_result;
    fi
  fi
done