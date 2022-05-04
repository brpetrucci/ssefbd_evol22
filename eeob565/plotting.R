### 
# get packages
library(ggplot2)
library(bayestestR)

### 
# reading logs

# set refs vector
refs <- c("1_base", "2_high_lambda1", "3_high_mu0", "4_low_q10")

# create data frame list
logs <- list()

# check how many we got
n <- list()

# for each ref
for (ref in refs) {
  # set up base directory
  base_dir <- paste0("/Users/petrucci/Documents/research/",
                     "ssefbd_evol22/eeob565/analysis/output/", ref)
  
  # start n
  n[[ref]] <- 0
  
  # for each rep
  for (rep in 1:100) {
    # get rep directory
    rep_dir <- paste0(base_dir, "/rep_", rep)
    
    # check whether rep directory exists and if so get a log
    if (dir.exists(rep_dir)) {
      # joint log file
      joint_log <- paste0(rep_dir, "/ssefbd.log")
      
      # check whether joint log exists and if so get it
      if (file.exists(joint_log)) {
        # increase n
        n[[ref]] <- n[[ref]] + 1
        
        # read log
        logs[[ref]][[n[[ref]]]] <- read.delim(joint_log)[, -1:-7]
        colnames(logs[[ref]][[n[[ref]]]]) <- c("lambda0", "lambda1", "mu0", "mu1",
                                          "q01", "q10")
      }
    }
  }
}

### 
# making plots

# list to hold data frame of means and 95% CI
means <- list()

# and one to hold the mode
modes <- list()

# get col names from each log
cnames <- colnames(logs[[refs[[1]]]][[1]])

# start our new colnames
cnamesMeans <- c()

# for each of the previous colnames
for (cname in cnames) {
  # get a low95, mean, and up95
  cnamesMeans <- c(cnamesMeans, paste0(cname, "low95"), paste0(cname, "mean"),
                   paste0(cname, "high95"))
}

# for each ref
for (ref in refs) {
  # initialize data frames
  means[[ref]] <- data.frame(matrix(ncol = 18, nrow = 0))

  modes[[ref]] <- data.frame(matrix(ncol = 6, nrow = 0))
  colnames(modes[[ref]]) <- cnames
  
  # for each log
  for (i in 1:length(logs[[ref]])) {
    # initialize vectors of results
    resMeans <- c()
    resModes <- c()
    
    # get this log
    log <- logs[[ref]][[i]]
    
    # for each column in log
    for (col in 1:ncol(log)) {
      # 97.5% and 2.5% quantiles
      quants <- quantile(log[, col], c(0.025, 0.975))
      
      # append to res with mean
      resMeans <- c(resMeans, quants[1], mean(log[, col]), quants[2])
      
      # get a mode estimate
      mode <- map_estimate(log[, col])
      
      # append to resModes
      resModes <- c(resModes, mode)
    }
    
    # add res to data frame
    means[[ref]] <- rbind(means[[ref]], resMeans)
    modes[[ref]] <- rbind(modes[[ref]], resModes)
  }
  
  # colnames
  colnames(means[[ref]]) <- cnamesMeans
}

# set up 6 plots
par(mfrow = c(3, 2))

# set up expected values
expec <- data.frame(lambda0 = rep(0.1, 4),
                    lambda1 = c(0.1, 0.2, 0.1, 0.1),
                    mu0 = c(0.03, 0.03, 0.06, 0.03),
                    mu1 = rep(0.03, 4),
                    q01 = rep(0.01, 4),
                    q10 = c(0.01, 0.01, 0.01, 0.005))

# for each ref
for (comb in 1:length(refs)) {
  # get ref
  ref <- refs[comb]
  
  # get means data frame
  meansRef <- means[[ref]]
  
  # for each parameter
  for (i in 1:6) {
    # get parameter name
    name <- colnames(logs[["1_base"]][[1]])[i]
    
    # get vectors of means and 95 CI
    low95 <- meansRef[, 3*(i - 1) + 1]
    mean <- meansRef[, 3*(i - 1) + 2]
    high95 <- meansRef[, 3*i]
    
    # plot the means
    plot(mean, ylab = "rate (events/lineage/my)", xlab = "rep",
         main = paste0("Mean and 95% CI of ", name, " for ", ref),
         ylim = c(0, max(high95) + max(high95)/5))
    
    # add lines for 95% CI
    lines(low95, col = "RED")
    lines(high95, col = "RED")
    
    # add expected line
    abline(h = expec[comb, i], col = "green")
  }
}

# 
par(mfrow = c(1, 1))

# data frame to compare high lambda1 to base
highLMeans <- cbind(c(rep("0.1", nrow(means[[1]])), rep("0.2", nrow(means[[2]]))),
                    rbind(means[[1]], means[[2]]))
colnames(highLMeans)[1] <- "ref"
                
# plot it      
ggplot(highLMeans, aes(x = lambda0mean, y = lambda1mean, colour = ref)) +
  geom_point() +
  geom_hline(yintercept = 0.1) +
  geom_vline(xintercept = 0.1) + 
  ggtitle("Lambda estimates in base vs. asymmetrical scenarios") +
  xlab("lambda0") + 
  ylab("lambad1") +
  labs(col = "True lambda1")

# data frame to compare high mu0 to base
highMMeans <- cbind(c(rep("0.03", nrow(means[[1]])), rep("0.06", nrow(means[[3]]))),
                    rbind(means[[1]], means[[3]]))
colnames(highMMeans)[1] <- "ref"

ggplot(highMMeans, aes(x = mu0mean, y = mu1mean, colour = ref)) +
  geom_point() +
  geom_vline(xintercept = 0.03) + 
  geom_hline(yintercept = 0.03) + 
  ggtitle("Mu estimates in base vs. asymmetrical scenarios") +
  xlab("mu0") + 
  ylab("mu1") +
  labs(col = "True mu0")

# data frame to compare low q10 to base
lowQMeans <- cbind(c(rep("0.01", nrow(means[[1]])), rep("0.005", nrow(means[[4]]))),
                    rbind(means[[1]], means[[4]]))
colnames(lowQMeans)[1] <- "ref"

ggplot(lowQMeans, aes(x = q01mean, y = q10mean, colour = ref)) +
  geom_point() +
  geom_hline(yintercept = 0.01) +
  geom_vline(xintercept = 0.01) + 
  ggtitle("Q estimates in base vs. asymmetrical scenarios") +
  xlab("q01") + 
  ylab("q10") +
  labs(col = "True q10")
