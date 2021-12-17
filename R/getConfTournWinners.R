#' Get Conference Tournament Winners
#'
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#'
#' @return A dataframe containing the conference tournament winners for each year in the dataset
#' @export
#'
#' @importFrom utils read.csv tail
#' @importFrom dplyr group_by arrange slice row_number ungroup select mutate
#'
#' @examples
#' #get conference tournament winners from stage 2 data
#' \dontrun{
#' confTournWinners <- getConfTournWinners(stage = 2)
#' }
#'
getConfTournWinners <- function(stage = 1) {

  if(stage == 1) {
    confTourn <- read.csv("MDataFiles_Stage1/MConferenceTourneyGames.csv")
  } else if(stage == 2) {
    confTourn <- read.csv("MDataFiles_Stage2/MConferenceTourneyGames.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  championship <- confTourn %>%
    group_by(Season, ConfAbbrev) %>%
    arrange(DayNum, .by_group = T) %>%
    slice(tail(row_number(), 1)) %>%
    ungroup()

  champ <- championship %>%
    select(Season, ConfAbbrev, TeamID = WTeamID) %>%
    mutate(confTournChamp = 1)

  return(champ)

}
