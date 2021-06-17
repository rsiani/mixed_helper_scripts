## MICROBIOLOGY WORKFLOW: GROWTH CURVES
# 16.06.21


## LIBRARIES

# pacman let's you load/install required packages

if (!require("pacman")) install.packages("pacman")

# NA NA NANA PACMAAAN

pacman::p_load(
  tidyverse,
  ggpubr,
  patchwork,
  hrbrthemes,
  growthcurver
  )

# easy-peasy, right?

## SETTINGS

# custom settings for the theme

theme_set(theme_ipsum(
  plot_margin = margin(1, 1, 1, 1),
  base_size = 20,
  grid = "XY",
  axis_title_size = 20,
  strip_text_size = 20
  ))

## GROWTH DATA

# you can either manually prepare your data.frame, so as to not have to reformat it

OD_600 =
  data.frame(
    ID =
      c(rep(c(rep("LjR118", 6), rep("LjR124", 6)), 11)),
    Rep =
      c(rep(rep(c(1 ,2 ,3 ,4 ,5 ,6), 2), 11)),
    time =
      c(rep(0, 12), rep(4, 12), rep(18, 12),
        rep(20, 12), rep(22, 12), rep(24, 12),
        rep(26, 12), rep(42, 12), rep(44, 12),
        rep(46, 12), rep(48, 12)),
    OD600 =
      c(5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        16, 15, 15, 19, 17, 18, 11, 14, 9, 14, 11, 10,
        246, 187, 211, 220, 211, 276, 173, 178, 195, 184, 182, 198,
        255, 213, 275, 245, 226, 249, 183, 215, 223, 208, 199, 205,
        289, 298, 286, 308, 274, 249, 229, 260, 235, 213, 255, 229,
        322, 327, 329, 304, 332, 278, 247, 276, 242, 242, 236, 269,
        336, 368, 364, 387, 361, 308, 276, 302, 286, 268, 269, 256,
        567, 609, 524, 587, 602, 571, 416, 468, 429, 455, 418, 422,
        625, 612, 555, 628, 619, 617, 428, 448, 470, 431, 431, 445,
        628, 638, 563, 633, 622, 627, 474, 452, 483, 448, 453, 469,
        626, 607, 631, 586, 617, 597, 462, 447, 452, 464, 496, 444)/1000
  )

# or you can read it from a file like this:

OD_600 =
  read_tsv(file = "Desktop/example_growthData.tsv") %>%
  pivot_longer(cols = -time,
               names_to = c("ID", "Rep"),
               values_to = "OD600",
               names_sep = "_")

## TEST

# a quick statistical testing is very practical to understand when your growth has reached the stationary test! In the example, you can see that after 42 hours the OD stays basically the same

res.test =
  compare_means(
    OD600 ~ time,
    data = OD_600,
    method = "wilcox.test",
    paired = T,
    group.by = "ID") %>%
  filter(p > 0.05)

# here you can see your average OD for different time point. If you wanna separate by ID, just change to group_by(time, ID)

summary_OD_600 =
  OD_600 %>%
  group_by(time) %>%
  summarise(Avg.OD = mean(OD600))

# now we can get some statistics for the growth (r, generation time, k ...) and get a "very nice" plot of the curves

growth_statistics =
  OD_600 %>%
  pivot_wider(
    names_from = c(ID, Rep),
    values_from = OD600) %>%
  SummarizeGrowthByPlate(
    .,
    bg_correct = "none",
    plot_fit = T,
    plot_file = paste(
      "growth_", Sys.Date(), ".pdf"
    ))

## PLOT

# pick some colors

nr2 =
  c("#236e96",
    "#15b2d3",
    "#ffd700",
    "#f3872f",
    "#ff598f")

# plot a nice graph

ggplot(OD_600,
       aes(x = time,
           y = OD600,
           color = ID,
           fill = ID)) +
  geom_smooth(alpha = 0.05) +
  theme(legend.position = "bottom") +
  labs(title = "Growth Curve: LjR118 vs LjR124",
       subtitle = "Minimal Media M9 supplemented with glucose and Lotus extract") +
  ylab(expression("OD"[600])) +
  xlab("Hours post inoculation") +
  scale_color_manual(values = c(nr2[2],
                                nr2[5])) +
  scale_fill_manual(values = c(nr2[2],
                               nr2[5])) +
  geom_point(alpha = 0.5) +
  scale_x_continuous(breaks = c(seq(0, max(OD_600$time), 2))) +
  scale_y_continuous(breaks = c(seq(0, 10, .1)))

# you can also navigate interactively if you want to impress your supervisor or your grandma

plotly::ggplotly(ggplot(OD_600,
                        aes(x = time,
                            y = OD600,
                            color = ID,
                            fill = ID)) +
                   geom_smooth(alpha = 0.05) +
                   theme(legend.position = "bottom") +
                   labs(title = "Growth Curve: LjR118 vs LjR124",
                        subtitle = "Minimal Media M9 supplemented with glucose and Lotus extract") +
                   ylab("OD600") +
                   xlab("Hours post inoculation") +
                   scale_color_manual(values = c(nr2[2],
                                                 nr2[5])) +
                   scale_fill_manual(values = c(nr2[2],
                                                nr2[5])) +
                   geom_point(alpha = 0.5) +
                   scale_x_continuous(breaks = c(seq(0, max(OD_600$time), 2))) +
                   scale_y_continuous(breaks = c(seq(0, 10, .1))))
