#' Get Summarized Rankings of Teams
#'
#' @param sysName The ranking system name(s) to filter the data by. Defaults to all, so all systems are used.
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#' @param ... Unquoted function names to use to summarize the ranking statistics, such as mean, median, or standard deviation. Will use mean if nothing is specified.
#'
#' @return A dataframe containing summarized rankings for each team in each season.
#' @export
#'
#' @importFrom utils read.csv
#' @importFrom rlang enquo quo_name parse_expr eval_tidy
#' @importFrom dplyr group_by summarise ungroup
#'
#' @examples
#' #get mean rankings based on all systems in stage 1
#' \dontrun{
#' rankings <- getRanks()
#' }
#'
#' #get mean and standard deviation of rankings based on the Massey (MAS) rankings and AP rankings
#' \dontrun{
#' rankings2 <- getRanks(sysName = c("MAS", "AP"), stage = 1, mean, sd)
#' }
#'
getRanks <- function(sysName = "all", stage = 1, ...) {

  if(stage == 1) {
    ranks <- read.csv("MDataFiles_Stage1/MMasseyOrdinals.csv")
  } else if(stage == 2) {
    ranks <- read.csv("MDataFiles_Stage2/MMasseyOrdinals.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  funcNames <- unlist(lapply(enquos(...), quo_name))

  if(length(funcNames) == 0) {
    funcNames <- "mean"
  }

  varLong <- rep("OrdinalRank", each = length(funcNames))


  newVarNameLong <- NULL

  for(i in 1:length(funcNames)) {
    newVarNameLong[i] <- paste(funcNames[i], varLong[i], sep = "")
  }

  possSys <- unique(ranks$SystemName)

  if(length(sysName == 1) & sysName[1] == "all") {
    langString <- paste("ranks %>% group_by(Season, TeamID) %>% summarise(",
                        paste(newVarNameLong, " = ",
                              funcNames,
                              "(", varLong, ")",
                              sep = "",
                              collapse = ", "),
                        ") %>% ungroup()", sep = "")
  } else if(length(sysName) == 1 & sysName[1] %in% possSys) {

    sysLong <- "SystemName"

    langString <- paste("ranks %>% filter(",
                        sysLong, "== '", sysName, "') %>% group_by(Season, TeamID) %>% summarise(",
                        paste(newVarNameLong, " = ",
                              funcNames,
                              "(", varLong, ")",
                              sep = "",
                              collapse = ", "),
                        ") %>% ungroup()", sep = "")
  } else if((length(sysName) > 1)) {

    isSys <- NULL

    for(i in 1:length(sysName)) {
      if(sysName[i] %in% possSys){
        isSys[i] <- sysName[i]
      }
    }
    if(length(isSys) == 0){
      stop("Invalid ranking system name(s).")
    } else{
      sysLong <- rep("SystemName", each = length(isSys))
      langString <- paste("ranks %>% filter(",
                          paste(sysLong, "== '", isSys, "'",
                               sep = "",
                               collapse = " | "),
                          ") %>% group_by(Season, TeamID) %>% summarise(",
                          paste(newVarNameLong, " = ",
                                funcNames,
                                "(", varLong, ")",
                                sep = "",
                                collapse = ", "),
                          ") %>% ungroup()", sep = "")
    }

  } else{
    stop("Invalid ranking system name(s).")
  }

  quoEval <- parse_expr(langString)

  eval_tidy(quoEval)

}
