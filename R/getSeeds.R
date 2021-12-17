#' Get Seeds for Tournament Teams
#'
#' @param stage Either 1 or 2, denotes the stage of the competition to use data from. Default is 1.
#'
#' @return A dataframe containing the seeds as integers for each tournament team in each season
#' @export
#'
#' @importFrom utils read.csv
#' @importFrom dplyr mutate
#'
#' @examples
#' #get tournament seeds for stage 2 data
#' \dontrun{
#' seeds <- getSeeds(stage = 2)
#' }
#'
getSeeds <- function(stage = 1) {

  if(stage == 1) {
    seeds <- read.csv("MDataFiles_Stage1/MNCAATourneySeeds.csv")
  } else if(stage == 2) {
    seeds <- read.csv("MDataFiles_Stage2/MNCAATourneySeeds.csv")
  } else {
    stop("Stage must be 1 or 2.")
  }

  seedsNoReg <- seeds %>%
    mutate(Seed = substring(Seed, first = 2))

  seedsNoReg$Seed <- sub("^0+", "", seedsNoReg$Seed)

  seedsNoReg$Seed <- sub("a$", "", seedsNoReg$Seed)

  seedsNoReg$Seed <- sub("b$", "", seedsNoReg$Seed)

  seedsNoReg$Seed <- as.integer(seedsNoReg$Seed)

  return(seedsNoReg)

}
