#' @title Create the NCAA Bracket Template
#'
#' @description Create the NCAA bracket with no teams filled in, only seeds
#' @return A ggplot object
#' @export
#'
#' @importFrom ggplot2 ggplot geom_segment geom_text aes theme_void
#'
bracketOutline <- function() {

  xStarts <- c(rep(1, 32), rep(2, 16), rep(3, 8), rep(4, 4), rep(5, 2), rep(2, 16), rep(3, 8), rep(4, 4), rep(5,2), 6,
               rep(13, 32), rep(12, 16), rep(11, 8), rep(10, 4), rep(9, 2), rep(12, 16), rep(11, 8), rep(10, 4), rep(9,2), 8, 6, 8, 6.5, 6.5, 6.5, 7.5)

  yStarts <- c(rep(c(seq(1, 16), seq(18, 33), seq(1.5, 15.5, by = 2), seq(18.5, 32.5, by = 2), seq(2.5, 14.5, by = 4), seq(19.5, 31.5, by = 4),
                     seq(4.5, 12.5, by = 8), seq(21.5, 29.5, by = 8), seq(8.5, 25.5, by = 17), seq(1, 15, by = 2), seq(18, 32, by = 2), seq(1.5, 13.5, by = 4),
                     seq(18.5, 30.5, by = 4), seq(2.5, 10.5, by = 8), seq(19.5, 27.5, by = 8), seq(4.5, 21.5, by = 17), 8.5), 2), 23, 11, 18, 16, 18, 16)

  xEnds <- c(rep(2, 32), rep(3, 16), rep(4, 8), rep(5, 4), rep(6, 2), rep(2, 16), rep(3, 8), rep(4, 4), rep(5, 2), 6,
             rep(12, 32), rep(11, 16), rep(10, 8), rep(9, 4), rep(8, 2), rep(12, 16), rep(11, 8), rep(10, 4), rep(9, 2), 8, 7, 7, 7.5, 7.5, 6.5, 7.5)

  yEnds <- c(rep(c(seq(1, 16), seq(18, 33), seq(1.5, 15.5, by = 2), seq(18.5, 32.5, by = 2), seq(2.5, 14.5, by = 4), seq(19.5, 31.5, by = 4),
                   seq(4.5, 12.5, by = 8), seq(21.5, 29.5, by = 8), seq(8.5, 25.5, by = 17), seq(2, 16, by = 2), seq(19, 33, by = 2), seq(3.5, 15.5, by = 4),
                   seq(20.5, 32.5, by = 4), seq(6.5, 14.5, by = 8), seq(23.5, 31.5, by = 8), seq(12.5, 29.5, by = 17), 25.5), 2), 23, 11, 18, 16, 16, 18)

  seeds <- rep(c(1, 16, 8, 9, 5, 12, 4, 13, 6, 11, 3, 14, 7, 10, 2, 15), 4)

  seedX <- c(rep(1.05, 32), rep(12.95, 32))

  seedY <- rep(c(seq(33.5, 18.5, by = -1), seq(16.5, 1.5, by = -1)), 2)

  bracket <- ggplot() +
    geom_segment(aes(x = xStarts, y = yStarts, xend = xEnds, yend = yEnds)) +
    geom_text(aes(x = seedX, y = seedY, label = seeds), size = 3) +
    theme_void()

  return(bracket)
}
