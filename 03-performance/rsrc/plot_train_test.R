ggTrainTestPlot = function (data, truth.fun, truth.min, truth.max, test.plot, test.ind, degrees = NULL)
{
	out = list()
	train.test.errors = list()

	x.truth = seq(from = truth.min, to = truth.max, length.out = 200)
	line.data = data.frame(x = x.truth, y = truth.fun(x.truth))

	temp = rep("Train set", nrow(data))
	temp[test.ind] = "Test set"
	data$dummy = factor(temp, levels = c("Train set", "Test set"))
	# browser()

	gg = ggplot() + 
	  geom_line(data = line.data, aes(x = x, y = y, size = "True relationship f(x)"), linetype = "longdash", colour = "grey") +
    scale_size_manual("", values = 0.5, guide = guide_legend(override.aes = list(colour = "grey"))) +
	  # geom_point(data = data[-ind, ], aes(x = x, y = y, fill = dummy)) +
	  # scale_color_identity(name = "", guide = "legend", labels = c("True relationship f(x)")) +
	  # scale_fill_identity(name = "", guide = "legend", labels = c("True relationship f(x)", "Training set")) +
	  xlab("") + ylab("")

	if (test.plot) {
		gg = gg + geom_point(data = data, aes(x = x, y = y, shape = dummy)) +
		scale_shape_manual(values = c(19, 1), guide = guide_legend(
        title = "",
        override.aes = list(
          size = 2
        )))
	} else {
		gg = gg + geom_point(data = data[-test.ind, ], aes(x = x, y = y, shape = dummy)) +
		scale_shape_manual(values = c(19, 1), guide = guide_legend(
        title = "",
        override.aes = list(
          size = 2
        )))
	}
	if (! is.null(degrees[1])) {
		
		df.poly = data.frame(x = numeric(0L), y = numeric(0L), degree = integer(0L))

		for (d in degrees) {

			temp.mod = lm(y ~ poly(x, degree = d), data = data[-test.ind, ])
			df.poly = rbind(df.poly, data.frame(
				x = x.truth, y = predict(temp.mod, newdata = data.frame(x = x.truth)), degree = d
			))

			train.test.errors[[paste0("degree", d)]] = c(train = mean((data$y[-test.ind] - predict(temp.mod))^2), 
				test = mean((data$y[test.ind] - predict(temp.mod, newdata = data.frame(x = data$x[test.ind])))^2))
		}

		df.poly$degree = as.factor(df.poly$degree)
		gg = gg + geom_line(data = df.poly, aes(x = x, y = y, color = degree))

		out[["train.test"]] = train.test.errors
	}

	out[["plot"]] = gg

	return (out)
}