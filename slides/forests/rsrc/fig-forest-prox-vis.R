set.seed(7)


library(palmerpenguins)
library(mlr3)
library(mlr3learners)
library(data.table)
library(ranger)
library(ggplot2)
library(MASS)
library(dplyr)

#### DATA PREP
data(penguins)
penguins <- na.omit(penguins)

# 20 samples per class are enough for clear visuals
penguins_sample <- penguins %>%
  group_by(species) %>%
  sample_n(20)

# manually add two outliers
outliers <- data.frame(
  species = c("Adelie", "Adelie"),
  island = c("Torgersen", "Biscoe"),
  bill_length_mm = c(70, 70),
  bill_depth_mm = c(211, 221),
  flipper_length_mm = c(333, 333),
  body_mass_g = c(6000, 6000),
  sex = c("male", "female"),
  year = c(2007, 2007)
)

# flip some labels
penguins_sample$species[7] <- "Chinstrap"
penguins_sample$species[32] <- "Gentoo"

# combine and create task
penguins_sample <- bind_rows(penguins_sample, outliers)
penguins_sample$species <- as.factor(penguins_sample$species)
task <- TaskClassif$new(id = "penguins", backend = penguins_sample, target = "species")

### FIT & PROXIMITIES
learner <- lrn("classif.ranger", predict_type = "prob")
learner$train(task)

# proximities
ranger_model <- learner$model
proximity <- predict(ranger_model, data = penguins_sample, type = "terminalNodes")$predictions
proximity <- as.matrix(proximity)

### VISUALIZATION
# distance matrix for plotting
distance_matrix <- 1 - proximity

# MDS for dimensionality reduction
mds <- cmdscale(as.dist(distance_matrix), k = 2)
mds_data <- data.table(mds, class = penguins_sample$species)
setnames(mds_data, c("V1", "V2"), c("Dim1", "Dim2"))

# column for points to highlight (potential outliers / flipped labels)
mds_data[, highlight := ifelse((.I == 29), TRUE, FALSE)]

# plot without highlighting outliers
p1 <- ggplot(mds_data, aes(x = Dim1, y = Dim2, color = class, shape = class)) +
  geom_point(aes(size = highlight), alpha = 0.7) +
  scale_color_manual(values = c("Adelie" = "#1f77b4", "Chinstrap" = "#ff7f0e", "Gentoo" = "#2ca02c")) +
  scale_size_manual(values = c('FALSE' = 7, 'TRUE' = 7), guide = "none") +
  scale_shape_manual(values = c("Adelie" = 16, "Chinstrap" = 17, "Gentoo" = 18)) + # Use different shapes
  labs(x = "dimension 1",
       y = "dimension 2") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    legend.title = element_text(size = 32),
    legend.text = element_text(size = 30),
    aspect.ratio = 1,
    legend.key.size = unit(1.5, 'lines')
  ) +
  guides(color = guide_legend(override.aes = list(size = 6)))
ggsave("../figure/forest-prox-vis_1.png", plot = p1, width = 8, height = 8, dpi = 300)


# Create a new column for color
mds_data$color <- ifelse(mds_data$highlight, "Highlighted", as.character(mds_data$class))

p2 <- ggplot(mds_data, aes(x = Dim1, y = Dim2)) +
  geom_point(aes(size = highlight, color = color, shape = class), alpha = 0.7) +
  scale_color_manual(values = c("Adelie" = "#1f77b4", "Chinstrap" = "#ff7f0e", "Gentoo" = "#2ca02c", "Highlighted" = "red"), guide = "none") +
  scale_size_manual(values = c('FALSE' = 7, 'TRUE' = 7), guide = "none") +
  scale_shape_manual(values = c("Adelie" = 16, "Chinstrap" = 17, "Gentoo" = 18)) + # Use different shapes
  labs(x = "dimension 1",
       y = "dimension 2") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    legend.title = element_text(size = 32),
    legend.text = element_text(size = 30),
    aspect.ratio = 1,
    legend.key.size = unit(1.5, 'lines')
  ) +
  guides(shape = guide_legend(override.aes = list(size = 6, color = c("#1f77b4", "#ff7f0e", "#2ca02c"))))
ggsave("../figure/forest-prox-vis_2.png", plot = p2, width = 8, height = 8, dpi = 300)
