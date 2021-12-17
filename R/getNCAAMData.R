#' @title Download and/or Read in Kaggle's NCAA Data
#'
#' @description Function to download Kaggle's 2021 March Mania competition data (if not already downloaded) and/or read in selected datasets
#' @return Vector of dataset names read in, as well as dataframes in the global environment for selected data. All datasets will also be downloaded to the current directory if not already there.
#' @export
#'
#'
#' @importFrom kaggler kgl_competitions_data_download_all kgl_competitions_data_list
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel
#' @importFrom shiny checkboxGroupInput observeEvent stopApp runGadget dialogViewer
#' @importFrom utils read.csv
#'
getNCAAMData <- function() {

  filesInCurrDir <- list.files()

  if(!("MDataFiles_Stage1" %in% filesInCurrDir)) {
    kgl_competitions_data_download_all("ncaam-march-mania-2021")
  }

  ncaaFiles <- kgl_competitions_data_list("ncaam-march-mania-2021")

  sortedFileNames <- ncaaFiles[order(ncaaFiles[,1]),1]

  vectorFiles <- sortedFileNames[[1]]

  ui <- miniPage(
    gadgetTitleBar("Select Which Datasets to Read In:"),
    miniContentPanel(
      checkboxGroupInput("datasets", "Available Datasets:", choices = vectorFiles)
    )
  )

  server <- function(input, output) {

    observeEvent(input$done, {

      for(dataset in input$datasets) {

        fileName <- substring(dataset, first = 19)

        noCSV <- sub(".csv", "", fileName)

        if(startsWith(x = dataset, prefix = "MDataFiles_Stage1")) {
          assign(paste0("Stage1", noCSV), read.csv(paste0("MDataFiles_Stage1/", fileName)), envir = .GlobalEnv)
        } else {
          assign(paste0("Stage2", noCSV), read.csv(paste0("MDataFiles_Stage2/", fileName)), envir = .GlobalEnv)
        }

      }

      stopApp(paste0("Datasets retrieved: ", input$datasets))
    })

    observeEvent(input$cancel, {
      stopApp(stop("No data retrieved.", call. = F))
    })
  }

  runGadget(ui, server, viewer = dialogViewer("Select Datasets", height = 500))
}
