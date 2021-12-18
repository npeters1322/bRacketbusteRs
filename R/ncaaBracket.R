#' Fill in Your NCAA Bracket
#'
#' @param season The season for the tournament. Defaults to 2021.
#' @param filled A logical value denoting whether to fill in winners. If filled = FALSE, the bracket will only show the first round with every team included. Defaults to FALSE.
#' @param fillData A vector containing your predicted winners for each game. The order should be: first round winners on left side of bracket from top to bottom, first round winners on right side of bracket from top to bottom, and so on for each round, with the champion being last. See an example below for an actual idea. If you choose a season with play-in games and want to predict the play-in games, please list those winners first. It would be beneficial to look at the unfilled bracket first so you know the correct order.
#'
#' @return
#' @export
#'
#' @importFrom rvest read_html html_nodes html_text
#' @importFrom ggplot2 geom_text geom_segment aes
#' @importFrom dplyr setdiff
#'
#' @examples
#' #get 2021 bracket, not filled in
#' \dontrun{
#' ncaaBracket()
#' }
#'
#' #get the 2014 bracket filled in with the actual winners
#' \dontrun{
#' ncaaBracket(season = 2014, filled = TRUE)
#' }
#'
#' #fill in the 2015 bracket with your own predictions
#' #first four are my predicted play-in winners, but you can exclude them if wanted
#' \dontrun{
#' predictions <- c("Hampton", "Dayton", "North Florida", "Ole Miss", "Kentucky", "Purdue", "West Virginia", "Maryland",
#'                  "Texas", "Notre Dame", "Indiana", "Kansas", "Wisconsin", "Oregon", "Arkansas", "North Carolina",
#'                  "Xavier", "Baylor", "Ohio State", "Arizona", "Villanova", "NC State", "Northern Iowa", "Louisville",
#'                  "Dayton", "Oklahoma", "Michigan State", "Virginia", "Duke", "St. John's", "Utah", "Georgetown",
#'                  "UCLA", "Iowa State", "Iowa", "Gonzaga", "Kentucky", "West Virginia", "Notre Dame", "Kansas",
#'                  "Wisconsin", "Arkansas", "Baylor", "Arizona", "Villanova", "Louisville", "Oklahoma", "Michigan State",
#'                  "Duke", "Utah", "Iowa State", "Gonzaga", "Kentucky", "Notre Dame", "Wisconsin", "Arizona", "Villanova",
#'                  "Michigan State", "Duke", "Iowa State", "Kentucky", "Wisconsin", "Michigan State", "Duke", "Kentucky",
#'                  "Duke", "Duke")
#'
#' ncaaBracket(season = 2015, filled = TRUE, fillData = predictions)
#' }
#'
#'
ncaaBracket <- function(season = 2021, filled = FALSE, fillData = NULL) {

  outline <- bracketOutline()

  if(as.integer(season) == 2021) {
    url <- 'http://www.espn.com/mens-college-basketball/tournament/bracket'
  } else {
    url <- paste0("http://www.espn.com/mens-college-basketball/tournament/bracket/_/id/", season, "22/", season, "-ncaa-tournament")
  }

  webpage <- read_html(url)

  round1 <- html_nodes(webpage, '.match.round1 dt a')

  if(length(round1) == 0){
    stop("Invalid season. Try any season between 2002 and 2021, excluding 2020.")
  }

  teams <- html_text(round1)

  teamsData <- data.frame(teams, xPos = c(rep(1.5, 32), rep(12.5, 32)), yPos = rep(c(seq(33.5, 18.5, by = -1), seq(16.5, 1.5, by = -1)), 2))

  playins <- html_nodes(webpage, '.playingames dt')

  if(length(playins) != 0){

    playinTeamsNoSeed <- html_nodes(webpage, '.playingames dt a')

    playinTeamsNoSeedVec <- html_text(playinTeamsNoSeed)

    playinTeams <- html_text(playins)

    seed_numbers <- regmatches(playinTeams, gregexpr("[[:digit:]]+", playinTeams))

    playinSeeds <- as.integer(unlist(seed_numbers))

    playinXStarts <- c(rep(4.7, 2), rep(5.9, 2), rep(8.1, 2), rep(9.3, 2), 5.7, 6.9, 7.1, 8.3)
    playinYStarts <- c(rep(c(1.5, 0.5), 4), rep(0.5, 4))
    playinXEnds <- c(rep(5.7, 2), rep(6.9, 2), rep(7.1, 2), rep(8.3, 2), 5.7, 6.9, 7.1, 8.3)
    playinYEnds <- c(rep(c(1.5, 0.5), 4), rep(1.5, 4))
    playinSeedSlotsX <- c(rep(4.75, 2), rep(5.95, 2), rep(8.05, 2), rep(9.25, 2))
    playinSeedSlotsY <- c(rep(c(1.75, 0.75), 4))
    playinTeamsSlotsX <- c(rep(5.2, 2), rep(6.4, 2), rep(7.6, 2), rep(8.8, 2))
    playinTeamsSlotsY <- c(rep(c(1.75, 0.75), 4))

    plotWithPlayin <- outline +
      geom_segment(aes(x = playinXStarts, y = playinYStarts, xend = playinXEnds, yend = playinYEnds)) +
      geom_text(aes(x = playinSeedSlotsX, y = playinSeedSlotsY, label = playinSeeds), size = 3) +
      geom_text(aes(x = playinTeamsSlotsX, y = playinTeamsSlotsY, label = playinTeamsNoSeedVec), size = 3)


    if(filled == FALSE){

      oddTeams <- playinTeamsNoSeedVec[c(1,3,5,7)]
      evenTeams <- playinTeamsNoSeedVec[c(2,4,6,8)]
      playinMatch <- paste(oddTeams, evenTeams, sep = "/")
      indexInTeams <- match(playinTeamsNoSeedVec, teams)
      noNA <- indexInTeams[!(is.na(indexInTeams))]
      teams2 <- teams
      teams2[noNA] <- playinMatch
      teamsData <- data.frame(teams2, xPos = c(rep(1.5, 32), rep(12.5, 32)), yPos = rep(c(seq(33.5, 18.5, by = -1), seq(16.5, 1.5, by = -1)), 2))
      finalBracket <- plotWithPlayin +
        geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams2), size = 3)

    } else if(filled == TRUE & is.null(fillData)) {

      teamsList <- list()
      for(i in 1:5) {
        nodes <- html_nodes(webpage, paste0('.match.round', i + 1, ' dt a'))
        teamsList[[i]] <- html_text(nodes)
      }
      champ <- html_nodes(webpage, '.match.round6 dt b a')
      champs <- html_text(champ)
      teamsFill <- c(teamsList[[1]], teamsList[[2]], teamsList[[3]], teamsList[[4]], teamsList[[5]], champs)
      teamsFillData <- data.frame(teamsFill, xPos = c(rep(2.5, 16), rep(11.5, 16), rep(3.5, 8), rep(10.5, 8), rep(4.5, 4), rep(9.5, 4), rep(5.5, 2), rep(8.5, 2), 6.5, 7.5, 7), yPos = c(rep(c(seq(33, 19, by = -2), seq(16, 2, by = -2)), 2), rep(c(seq(32, 20, by = -4), seq(15, 3, by = -4)), 2), rep(c(seq(30, 22, by = -8), seq(13, 5, by =-8)), 2), rep(c(26, 9), 2), 23.5, 11.5, 17))
      finalBracket <- plotWithPlayin +
        geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams), size = 3) +
        geom_text(data = teamsFillData, aes(x = xPos, y = yPos, label = teamsFill), size = 3)

    } else {
      #fill with user's data
      if(length(fillData) == 67){

        indexInFill <- match(playinTeamsNoSeedVec, fillData)
        noNA <- indexInFill[!(is.na(indexInFill))]
        playinWinners <- fillData[noNA]
        predLosers <- setdiff(playinTeamsNoSeedVec, playinWinners)

        indexInTeams <- match(playinTeamsNoSeedVec, teams)
        noNATeams <- indexInTeams[!(is.na(indexInTeams))]

        teamsWithPredPlayin <- replace(teams, noNATeams, playinWinners)

        teamsPredPlayinData <- data.frame(teamsWithPredPlayin, xPos = c(rep(1.5, 32), rep(12.5, 32)), yPos = rep(c(seq(33.5, 18.5, by = -1), seq(16.5, 1.5, by = -1)), 2))

        predsNoPlayinWinners <- fillData[-c(noNA)]

        teamsFillData <- data.frame(predsNoPlayinWinners, xPos = c(rep(2.5, 16), rep(11.5, 16), rep(3.5, 8), rep(10.5, 8), rep(4.5, 4), rep(9.5, 4), rep(5.5, 2), rep(8.5, 2), 6.5, 7.5, 7), yPos = c(rep(c(seq(33, 19, by = -2), seq(16, 2, by = -2)), 2), rep(c(seq(32, 20, by = -4), seq(15, 3, by = -4)), 2), rep(c(seq(30, 22, by = -8), seq(13, 5, by =-8)), 2), rep(c(26, 9), 2), 23.5, 11.5, 17))

        finalBracket <- plotWithPlayin +
          geom_text(data = teamsPredPlayinData, aes(x = xPos, y = yPos, label = teamsWithPredPlayin), size = 3) +
          geom_text(data = teamsFillData, aes(x = xPos, y = yPos, label = predsNoPlayinWinners), size = 3)


      } else {
        userData <- data.frame(fillData, xPos = c(rep(2.5, 16), rep(11.5, 16), rep(3.5, 8), rep(10.5, 8), rep(4.5, 4), rep(9.5, 4), rep(5.5, 2), rep(8.5, 2), 6.5, 7.5, 7), yPos = c(rep(c(seq(33, 19, by = -2), seq(16, 2, by = -2)), 2), rep(c(seq(32, 20, by = -4), seq(15, 3, by = -4)), 2), rep(c(seq(30, 22, by = -8), seq(13, 5, by =-8)), 2), rep(c(26, 9), 2), 23.5, 11.5, 17))
        finalBracket <- plotWithPlayin +
          geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams), size = 3) +
          geom_text(data = userData, aes(x = xPos, y = yPos, label = fillData), size = 3)
      }
    }


  } else {

    if(filled == FALSE) {

      finalBracket <- outline +
        geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams), size = 3)

    }else if(filled == TRUE & is.null(fillData)) {

      teamsList <- list()
      for(i in 1:5) {
        nodes <- html_nodes(webpage, paste0('.match.round', i + 1, ' dt a'))
        teamsList[[i]] <- html_text(nodes)
      }
      champ <- html_nodes(webpage, '.match.round6 dt b a')
      champs <- html_text(champ)
      teamsFill <- c(teamsList[[1]], teamsList[[2]], teamsList[[3]], teamsList[[4]], teamsList[[5]], champs)
      teamsFillData <- data.frame(teamsFill, xPos = c(rep(2.5, 16), rep(11.5, 16), rep(3.5, 8), rep(10.5, 8), rep(4.5, 4), rep(9.5, 4), rep(5.5, 2), rep(8.5, 2), 6.5, 7.5, 7), yPos = c(rep(c(seq(33, 19, by = -2), seq(16, 2, by = -2)), 2), rep(c(seq(32, 20, by = -4), seq(15, 3, by = -4)), 2), rep(c(seq(30, 22, by = -8), seq(13, 5, by =-8)), 2), rep(c(26, 9), 2), 23.5, 11.5, 17))
      finalBracket <- outline +
        geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams), size = 3) +
        geom_text(data = teamsFillData, aes(x = xPos, y = yPos, label = teamsFill), size = 3)

    }else{

      userData <- data.frame(fillData, xPos = c(rep(2.5, 16), rep(11.5, 16), rep(3.5, 8), rep(10.5, 8), rep(4.5, 4), rep(9.5, 4), rep(5.5, 2), rep(8.5, 2), 6.5, 7.5, 7), yPos = c(rep(c(seq(33, 19, by = -2), seq(16, 2, by = -2)), 2), rep(c(seq(32, 20, by = -4), seq(15, 3, by = -4)), 2), rep(c(seq(30, 22, by = -8), seq(13, 5, by =-8)), 2), rep(c(26, 9), 2), 23.5, 11.5, 17))
      finalBracket <- outline +
        geom_text(data = teamsData, aes(x = xPos, y = yPos, label = teams), size = 3) +
        geom_text(data = userData, aes(x = xPos, y = yPos, label = fillData), size = 3)

    }

  }

  return(finalBracket)

}


