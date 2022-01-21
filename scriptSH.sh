#!/bin/bash

ADD_MOVIE() {
    echo -e "\nWhat is name of the movie?" 
    read MOVIE

    $(curl -s https://imdb-api.com/en/API/SearchMovie/"${imdbAPIkey}"/"${MOVIE}" -o imdbSearch.json)
    jq . imdbSearch.json | sponge imdbSearch.json
    LENGTH=$(jq -r '.results | length' imdbSearch.json)

    #for i in $(seq 0 $LENGTH);
    i=0
    until [ $i -gt $LENGTH ]
    do
        MOVIE_NAME=$( jq -r '.results['$i'].title' imdbSearch.json )
        if [ "$MOVIE_NAME" == "null" ]; then
            echo -e "\nCan you be more specific?"
            ADD_MOVIE
            break
        fi
        echo "Is this the movie you are looking for (Y y - N n)?"
        echo -e "${MOVIE_NAME}"
        read yn
        case $yn in
            [Yy]* ) 
                MOVIE_ID=$( jq -r '.results['$i'].id' imdbSearch.json ) 
                break ;;
            [Nn]* ) 
                ((i++))
                ;;
            * ) 
                echo "Please answer yes or no (Y y - N n)."
                ;;
        esac
    done

    if [ ! -d "$PWD/VIDEOTECA" ]; then
        mkdir "$PWD/VIDEOTECA"
        mkdir "$PWD/VIDEOTECA/MOVIES"
    elif [ ! -d "$PWD/VIDEOTECA/MOVIES" ]; then
        mkdir "$PWD/VIDEOTECA/MOVIES"
    fi
    if [ ! -f "$PWD/VIDEOTECA/MOVIES/${MOVIE_NAME}.txt" ]; then
        touch "$PWD/VIDEOTECA/MOVIES/${MOVIE_NAME}.txt"
    fi

    rm imdbSearch.json
    $(curl -s https://imdb-api.com/en/API/Title/"${imdbAPIkey}"/"${MOVIE_ID}"/FullActor,Ratings, -o imdbMovie.json )
    jq . imdbMovie.json | sponge imdbMovie.json

    MOVIE_PATH="$PWD/VIDEOTECA/MOVIES/${MOVIE_NAME}.txt"
    genrsArr=( $( jq '.genreList[].key' imdbMovie.json ) )

    content="\
Id: $(jq -r '.id' imdbMovie.json)\n\
Title: $(jq -r '.title' imdbMovie.json) (Full title: $(jq -r '.fullTitle' imdbMovie.json))\n\
Realese Date: $(jq -r '.releaseDate' imdbMovie.json)\n\
Runtime: $(jq -r '.runtimeStr' imdbMovie.json) (Runtime in minutes $(jq -r '.runtimeMins' imdbMovie.json) mins)\n\
Star/s actor/s: $(jq -r '.stars' imdbMovie.json)\n\
Diretor/s: $(jq -r '.directors' imdbMovie.json)\n\
Writer/s: $(jq -r '.writers' imdbMovie.json)\n\
Companies: $(jq -r '.companies' imdbMovie.json)\n\
\n\
Plot: $(jq -r '.plot' imdbMovie.json)\n\
\n\
Genres: ${genrsArr[@]}\n\
\n\
Content Rating: $(jq -r '.contentRating' imdbMovie.json)\n\
ImDb Rating: $(jq -r '.imDbRating' imdbMovie.json) (With $(jq -r '.imDbRatingVotes' imdbMovie.json) votes)\n\
Metacritic Rating: $(jq -r '.metacriticRating' imdbMovie.json)\n\
Rotten Tomatoes: $(jq -r '.ratings.rottenTomatoes' imdbMovie.json)\n\
\n\
Budget: $(jq -r '.boxOffice.budget' imdbMovie.json)\n\
Opening Weekend USA: $(jq -r '.boxOffice.budget' imdbMovie.json)\n\
Gross USA: $(jq -r '.boxOffice.grossUSA' imdbMovie.json)\n\
Cumulative Worldwide Gross: $(jq -r '.boxOffice.cumulativeWorldwideGross' imdbMovie.json)\n"

    rm imdbMovie.json
    echo -e "$content" > "$MOVIE_PATH"
    
    IFS=$'\n'
    for i in "$MOVIE_PATH" ; 
    do 
        fold -w100 -s $i > sillytmpfile; 
        mv sillytmpfile $i; 
    done
    unset IFS;
    
    if [ -f "$MOVIE_PATH" ]; then
        notify-send "The file ${MOVIE_NAME}.txt was successfully created!!"
    else 
        notify-send "The file ${MOVIE_NAME}.txt was not successfully created!!"                
    fi
}
#####################################################################################################
#####################################################################################################
ADD_SERIE() {
    echo -e "\nWhat is name of the serie?" 
    read SERIE

    $(curl -s https://imdb-api.com/en/API/SearchSeries/"${imdbAPIkey}"/"${SERIE}" -o imdbSearch.json)
    jq . imdbSearch.json | sponge imdbSearch.json
    LENGTH=$(jq -r '.results | length' imdbSearch.json)

    i=0
    until [ $i -gt $LENGTH ]
    do
        SERIE_NAME=$( jq -r '.results['$i'].title' imdbSearch.json )
        if [ "$SERIE_NAME" == "null" ]; then
            echo -e "\nCan you be more specific?"
            ADD_SERIE
            break
        fi
        echo "Is this the serie you are looking for (Y y - N n)?"
        echo -e "${SERIE_NAME}"
        read yn
        case $yn in
            [Yy]* ) 
                SERIE_ID=$( jq -r '.results['$i'].id' imdbSearch.json )
                break ;;
            [Nn]* ) 
                ((i++)) ;;
            * ) 
                echo "Please answer yes or no (Y y - N n)." ;;
        esac
    done

    if [ ! -d "$PWD/VIDEOTECA" ]; then
        mkdir "$PWD/VIDEOTECA"
        mkdir "$PWD/VIDEOTECA/SERIES"
    elif [ ! -d "$PWD/VIDEOTECA/SERIES" ]; then
        mkdir "$PWD/VIDEOTECA/SERIES"
    fi
    if [ ! -f "$PWD/VIDEOTECA/SERIES/${SERIE_NAME}.txt" ]; then
        touch "$PWD/VIDEOTECA/SERIES/${SERIE_NAME}.txt"
    fi

    rm imdbSearch.json
    $(curl -s https://imdb-api.com/en/API/Title/"${imdbAPIkey}"/"${SERIE_ID}"/Ratings, -o imdbSerie.json )
    jq . imdbSerie.json | sponge imdbSerie.json

    SERIE_PATH="$PWD/VIDEOTECA/SERIES/${SERIE_NAME}.txt"
    genresArr=( $( jq '.genreList[].key' imdbSerie.json ) )
    seasonLength=$(jq -r '.tvSeriesInfo.seasons | length' imdbSerie.json)

    content="\
Id: $(jq -r '.id' imdbSerie.json)\n\
Title: $(jq -r '.title' imdbSerie.json) (Full title: $(jq -r '.fullTitle' imdbSerie.json))\n\
Realese Date: $(jq -r '.releaseDate' imdbSerie.json)\n\
Seasons: ${seasonLength}\n\
Star/s actor/s: $(jq -r '.stars' imdbSerie.json)\n\
Companies: $(jq -r '.companies' imdbSerie.json)\n\
\n\
Plot: $(jq -r '.plot' imdbSerie.json)\n\
\n\
Genres: ${genresArr[@]}\n\
\n\
Content Rating: $(jq -r '.contentRating' imdbSerie.json)\n\
ImDb Rating: $(jq -r '.imDbRating' imdbSerie.json) (With $(jq -r '.imDbRatingVotes' imdbSerie.json) votes)\n\
Metacritic Rating: $(jq -r '.metacriticRating' imdbSerie.json)\n\
Rotten Tomatoes: $(jq -r '.ratings.rottenTomatoes' imdbSerie.json)\n"


    rm imdbSerie.json
    echo -e "$content" > "$SERIE_PATH"
    
    IFS=$'\n'
    for j in "$SERIE_PATH" ; 
    do 
        fold -w100 -s $j > sillytmpfile; 
        mv sillytmpfile $j; 
    done
    unset IFS;

    if [ -f "$SERIE_PATH" ]; then
        notify-send "The file ${SERIE_NAME}.txt was successfully created!!"
    else 
        notify-send "The file ${SERIE_NAME}.txt was not successfully created!!"                
    fi
}
#####################################################################################################
#####################################################################################################
MENU_GENRE() {
    genreArray=("." "Action" "Adult" "Adventure" "Animation" "Biography" "Comedy" 
                "Crime" "Documentary" "Drama" "Family" "Fantasy" "Film Noir" 
                "Game Show" "History" "Horror" "Musical" "Music" "Mystery" 
                "News" "Reality-TV" "Romance" "Sci-Fi" "Short" "Sport" 
                "Talk-Show" "Thriller" "War" "Western" )

    while :
    do
        clear

        echo -e "Please choose an option between 1-27"
        echo -e "\
---------------------------------------------------------------------------- \n\
|  1 - Action         2 - Adult         3 - Adventure     4 - Animation    | \n\
|  5 - Biography      6 - Comedy        7 - Crime         8 - Documentary  | \n\
|  9 - Drama          10 - Family       11 - Fantasy      12 - Film Noir   | \n\
|  13 - Game Show     14 - History      15 - Horror       16 - Musical     | \n\
|  17 - Music         18 - Mystery      19 - News         20 - Reality-TV  | \n\
|  21 - Romance       21 - Sci-Fi       22 - Short        23 - Sport       | \n\
|  24 - Talk-Show     25 - Thriller     26 - War          27 - Western     | \n\
----------------------------------------------------------------------------"
        
        read op
        if ((op>=1 && op<=27)); then
            break
        fi
        
        echo -e "Please choose a correct option\n"
        read -n 1 -s -r -p "Press any key to continue..."
        
    done
}
#####################################################################################################
#####################################################################################################
OPEN_FILE() {
    
    echo -e "\nDo you want to see the content of any of this files (Y y - N n)?"
    while :
    do  
        read yn
        case $yn in
            [Yy]* ) 
                echo "Chose one of them (ATENTION: copy the name exactly!)."
                read openFile
                file="${dir}/${openFile}.txt"

                if [ -f "$file" ]; then
                    while IFS= read -r line
                    do
                        echo "$line"
                    done < "$file" 
                    break
                else
                    echo -e "Didn't find any movie/serie with the name $openFile"
                    break
                fi;;
            [Nn]* ) 
                break ;;
            * ) 
                echo "Please answer yes or no (Y y - N n)." ;;
        esac
    done
}
#####################################################################################################
#####################################################################################################
FIND_MOVIE_SERIE() {
    #count how many files in a directory
    #ls -1 | wc -l
    MENU_GENRE
    wordTF=\"${genreArray[$op]}\"

    if grep -qr "$wordTF" "$dir"; then
        echo -e "\n"
        IFS=$'\n'
        array=($(grep -rl "$dir" -e "$wordTF"))
        for element in "${array[@]##*/}"
        do
            element=${element%.txt}
            echo "$element"
        done
        unset IFS;
        
        OPEN_FILE
    else
        echo "Didn't find any movie/series with the genre $wordTF"
    fi

    echo -e "\n"
    read -n 1 -s -r -p "Press any key to continue..."
}
#####################################################################################################
#####################################################################################################
SEE_MOVIE_SERIE() {
    echo -e "\n"
    IFS=$'\n'
    for entry in "$dir"/*
    do
        entry=${entry##*/}
        entry=${entry%.txt}
        echo "$entry"
    done
    unset IFS;

    OPEN_FILE

    echo -e "\n"
    read -n 1 -s -r -p "Press any key to continue..."
}
#####################################################################################################
#####################################################################################################
DELETE_MOVIE_SERIE() {
    echo "Chose one of them (ATENTION: copy the name exactly!)."
    read openFile

    file="${dir}/${openFile}.txt"
    if [ -f "$file" ]; then
        echo "Are you sure you want to delete ${file} (Y y - N n)?"
        read yn
        while :
        do
            case $yn in
                [Yy]* ) 
                    rm -- "$file"
                    break ;;
                [Nn]* ) 
                    break ;;
                * ) 
                    echo "Please answer yes or no (Y y - N n)." ;;
            esac
        done
    else
        echo -e "Didn't find any movie/serie with the name $openFile"
    fi
    
    echo -e "\n"
    read -n 1 -s -r -p "Press any key to continue..."
}
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
cd "$(dirname "${BASH_SOURCE[0]}")"

#My key to acesss imdb API
imdbAPIkey="k_3fe0i6hl"

while :
do
    clear
    echo -e "Please choose an option between 0-8 (0 to exit)"
    echo -e "\
---------------------------------------------------------------------------- \n\
|    0 - Leave                                                             | \n\
|    1 - Add movie                   2 - Add series                        | \n\
|    3 - See movie/s                 4 - See serie/s                       | \n\
|    5 - Find movie by genre         6 - Find serie by genre               | \n\
|    7 - Delete movie                8 - Delete serie                      | \n\
|    9 - Zip directory               10 - Unzip directory                  | \n\
----------------------------------------------------------------------------"
    echo -e "Option: "
    read op
    case $op in
        0)
            echo "Okay, goodbye!!" 
            read -n 1 -s -r -p "Press any key to continue..."
            exit;;
        1)
            ADD_MOVIE;;
        2)
            ADD_SERIE;;
        3)
            dir="$PWD/VIDEOTECA/MOVIES"
            SEE_MOVIE_SERIE;;
        4)
            dir="$PWD/VIDEOTECA/SERIES"
            SEE_MOVIE_SERIE;;
        5)
            dir="$PWD/VIDEOTECA/MOVIES"
            FIND_MOVIE_SERIE;;
        6)
            dir="$PWD/VIDEOTECA/SERIES"
            FIND_MOVIE_SERIE;;
        7)
            dir="$PWD/VIDEOTECA/MOVIES"
            DELETE_MOVIE_SERIE;;
        8)
            dir="$PWD/VIDEOTECA/SERIES"
            DELETE_MOVIE_SERIE;;
        9)
            if [ -d "$PWD/VIDEOTECA" ]; then 
                zip -r VIDEOTECA.zip VIDEOTECA/
                if [ -f "$PWD/VIDEOTECA.zip" ]; then
                    notify-send "The file VIDEOTECA.zip was successfully created!!"
                else
                    notify-send "The file was not successfully created!!"
                fi
            else
                notify-send "The directory VIDEOTECA does not exist!!"
            fi;;
        10)
            if [ -f "$PWD/VIDEOTECA.zip" ]; then
                unzip VIDEOTECA.zip
                if [ -d "$PWD/VIDEOTECA" ]; then
                    notify-send "The dir VIDEOTECA was successfully created!!"
                else
                    notify-send "The dir VIDEOTECA was not successfully created!!"
                fi
            else
                notify-send "No file VIDEOTECA.zip to unzip!!"                
            fi;;
        *)
            echo "Please choose a correct option"
            read -n 1 -s -r -p "Press any key to continue...";;
    esac
    echo -e "\n"
done