#' Get Different Records for Teams
#'
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#'
#' @return A dataframe containing wins, losses, and win percentages for various types of games (home, away, neutral) for each team in each season
#' @export
#'
#' @importFrom utils read.csv
#' @importFrom dplyr select group_by summarise ungroup n rename full_join mutate
#' @importFrom tidyr spread
#'
#' @examples
#' #get stage 2 records data
#' \dontrun{
#' records <- getRecords(stage = 2)
#' }
#'
getRecords <- function(stage = 1) {

  if(stage == 1) {
    regStats <- read.csv("MDataFiles_Stage1/MRegularSeasonDetailedResults.csv")
  } else if(stage == 2) {
    regStats <- read.csv("MDataFiles_Stage2/MRegularSeasonDetailedResults.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  regStats <- regStats %>%
    select(Season, WTeamID, LTeamID, WLoc)

  wins <- regStats %>%
    group_by(Season, WTeamID, WLoc) %>%
    summarise(wins = n()) %>%
    ungroup()

  winsWide <- spread(wins, WLoc, wins)

  winsWide[is.na(winsWide)] <- 0

  winsWide <- winsWide %>%
    rename(TeamID = WTeamID, aWins = A, hWins = H, nWins = N)

  losses <- regStats %>%
    group_by(Season, LTeamID, WLoc) %>%
    summarise(losses = n()) %>%
    ungroup()

  lossesWide <- spread(losses, WLoc, losses)

  lossesWide <- lossesWide %>%
    rename(TeamID = LTeamID, aLosses = H, hLosses = A, nLosses = N)

  lossesWide[is.na(lossesWide)] <- 0

  allRecords <- winsWide %>%
    full_join(lossesWide, by = c("Season", "TeamID"))

  allRecords[is.na(allRecords)] <- 0

  allRecords <- allRecords %>%
    mutate(hWPct = (hWins / (hWins + hLosses)), aWPct = (aWins / (aWins + aLosses)), nWPct = (nWins / (nWins + nLosses)))

  allRecords[is.na(allRecords)] <- 0

  return(allRecords)
}
