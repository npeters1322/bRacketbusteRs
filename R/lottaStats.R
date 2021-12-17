#' Put Other Statistic Functions Together...and Add a Little More
#'
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#' @param rankSysName The ranking system name(s) to filter the data by. Defaults to all, so all systems are used.
#'
#' @return A dataframe containing average per-game statistics, average rankings, conference, team name, seed (NA if they didn't make the tournament), and if the team won the conference tournament for each team in each season.
#' @export
#'
#' @importFrom utils read.csv
#' @importFrom dplyr select inner_join full_join filter
#'
#' @examples
#' #get all the variables using stage 2 data and all ranking systems
#' \dontrun{
#' bigStats <- lottaStats(stage = 2, rankSysName = "all")
#' }
#'
#' #use stage 1 data and only the Massey (MAS) rankings
#' \dontrun{
#' bigStats2 <- lottaStats(stage = 1, rankSysName = "MAS")
#' }
#'
lottaStats <- function(stage = 1, rankSysName = "all") {

  if(stage == 1) {
    stageNum <- 1
    confs <- read.csv("MDataFiles_Stage1/MTeamConferences.csv")
    teams <- read.csv("MDataFiles_Stage1/MTeams.csv")
  } else if(stage == 2) {
    stageNum <- 2
    confs <- read.csv("MDataFiles_Stage2/MTeamConferences.csv")
    teams <- read.csv("MDataFiles_Stage2/MTeams.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  teams <- teams %>%
    select(TeamID, TeamName)

  sysName <- rankSysName

  rankings <- getRanks(sysName = sysName, stage = stageNum, mean)
  pgStats <- perGameStats(stage = stageNum, mean)
  confTournWinner <- getConfTournWinners(stage = stageNum)
  records <- getRecords(stage = stageNum)
  seeds <- getSeeds(stage = stageNum)

  manyStats <- teams %>%
    inner_join(rankings, by = c("TeamID" = "TeamID")) %>%
    inner_join(records, by = c("Season" = "Season", "TeamID" = "TeamID")) %>%
    inner_join(confs, by = c("Season" = "Season", "TeamID" = "TeamID")) %>%
    full_join(confTournWinner, by = c("Season" = "Season", "TeamID" = "TeamID", "ConfAbbrev" = "ConfAbbrev")) %>%
    filter(Season > 2002)

  manyStats[is.na(manyStats)] <- 0

  manyStats <- manyStats %>%
    full_join(seeds, by = c("Season" = "Season", "TeamID" = "TeamID")) %>%
    filter(Season > 2002) %>%
    full_join(pgStats, by = c("Season" = "Season", "TeamID" = "TeamID"))

  return(manyStats)

}

