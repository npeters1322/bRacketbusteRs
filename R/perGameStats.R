#' Get Per-Game Statistics
#'
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#' @param ... Unquoted function names to use to summarize the per-game statistics, such as mean, median, or standard deviation. Will use mean if nothing is specified.
#'
#' @return A dataframe containing summarized statistics for each team in each season.
#' @export
#'
#' @importFrom utils read.csv
#' @importFrom rlang enquos quo_name parse_expr eval_tidy
#' @importFrom dplyr rename_with select group_by summarise ungroup
#'
#' @examples
#' #will use stage 1 data and calculate the mean for each of the statistics
#' \dontrun{
#' avgStatsPerGame <- perGameStats()
#' }
#'
#' #will use stage 2 data and calculate the mean, median, and standard deviation of each statistic
#' \dontrun{
#' perGameStats(stage = 2, mean, median, sd)
#' }
#'
perGameStats <- function(stage = 1, ...) {

  if(stage == 1) {
    regStats <- read.csv("MDataFiles_Stage1/MRegularSeasonDetailedResults.csv")
  } else if(stage == 2) {
    regStats <- read.csv("MDataFiles_Stage2/MRegularSeasonDetailedResults.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  funcNames <- unlist(lapply(enquos(...), quo_name))

  if(length(funcNames) == 0) {
    funcNames <- "mean"
  }

  wStats <- regStats %>%
    rename_with(~sub("W", "", .x)) %>%
    select(-c(DayNum, LTeamID, Loc, NumOT)) %>%
    rename_with(~sub("L", "Opp", .x))

  lStats <- regStats %>%
    rename_with(~sub("L", "", .x)) %>%
    select(-c(DayNum, WTeamID, Woc, NumOT)) %>%
    rename_with(~sub("W", "Opp", .x))

  allStats <- rbind(wStats, lStats)

  varLong <- rep(names(allStats)[-(1:2)], each = length(funcNames))

  numStats <- length(names(allStats)[-(1:2)])

  funcNamesLong <- rep(funcNames, times = numStats)

  newVarNameLong <- NULL

  for(i in 1:length(funcNamesLong)) {
    newVarNameLong[i] <- paste(funcNamesLong[i], varLong[i], sep = "")
  }

  langString <- paste("allStats %>% group_by(Season, TeamID) %>% summarise(",
                      paste(newVarNameLong, " = ",
                            funcNamesLong,
                            "(", varLong, ")",
                            sep = "",
                            collapse = ", "),
                      ") %>% ungroup()", sep = "")

  quoEval <- parse_expr(langString)

  finalOutput <- eval_tidy(quoEval)

  return(finalOutput)

}
