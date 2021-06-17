#0# ---------------------------------------------------------------------------------
##
## Name: Pairwise Comparison of 2 Acidovorax strains
## Author: Roberto Siani, MSc
## Date: 200521
## Contact: roberto.siani@helmholtz-muenchen.de

#1# ---------------------------------------------------------------------------------


#1.1# load libraries

pacman::p_load(tidyverse,
               ggpubr,
               patchwork,
               hrbrthemes)

#1.2# set a general theme for viz

theme_set(theme_ipsum(
  plot_margin = margin(0, 0, 1, 1),
  base_size = 15,
  grid = "XY",
  axis_title_size = 15))

#1.3# set a palette

pal = c("#a6bba6",
        "#bba6bb")


#2# ---------------------------------------------------------------------------------

#2.1# load exported annotation tsv from MG-RAST

mgrast = read_tsv("~/Desktop/extras/mgrast_ko.tsv",
                  col_types = "ffffnn") %>%
  mutate(level3 = gsub(x = .$level3,
                       pattern = "\\[[^()]*\\]",
                       replacement = "")) %>%
  mutate(level3 = gsub(x = .$level3,
                       pattern = "^\\d+",
                       replacement = ""))

#2.2# convert to relative abundance

perc_mgrast = mgrast %>%
  mutate(LjR118 = LjRoot118/sum(LjRoot118)*100,
         LjR124 = LjRoot124/sum(LjRoot124)*100) %>%
  select(-c(LjRoot118, LjRoot124))

#2.3# convert to long format

long_mgrast = perc_mgrast %>%
  pivot_longer(cols = 5:6,
               names_to = "Strain",
               values_to = "p_tot")



a = ggplot(long_mgrast,
           aes(x = level1,
               y = p_tot,
               fill = Strain)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  coord_flip() +
  stat_compare_means(method = "wilcox.test",
                     paired = T,
                     label = "p.signif",
                     hide.ns = T)  +
  theme(legend.position = "bottom",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size = 12)) +
  scale_fill_manual(values = pal)

b = ggplot(long_mgrast,
           aes(x = level2,
               y = p_tot,
               fill = Strain)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  coord_flip() +
  stat_compare_means(method = "wilcox.test",
                     paired = T,
                     label = "p.signif",
                     hide.ns = T)  +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size = 10)) +
  scale_fill_manual(values = pal)

c = ggplot(long_mgrast,
           aes(x = level3,
               y = p_tot,
               fill = Strain)) +
  geom_bar(stat = "identity",
           position = "dodge") +
  coord_flip() +
  stat_compare_means(method = "wilcox.test",
                     paired = T,
                     label = "p.signif",
                     hide.ns = T)  +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size = 8)) +
  scale_fill_manual(values = pal)

a + b + c +
  theme(axis.title = element_blank()) +
  plot_layout(widths = c(0.8, 1, 1.2))
