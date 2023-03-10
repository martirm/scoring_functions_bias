library(clustAnalytics)
library(pbapply)

# This script contains the code to perform the experiments of the multi-level
# stochastic block model (SBM) graph. The output is saved at "multi_level_SBM_data.RData"
# to be plotted in "multi_level_analysis.R".


ground_truth_sbm <- function(blocks=c(40,25,25,10)){
    indices <- 1:length(blocks)
    unlist(mapply(rep, indices, blocks, SIMPLIFY=FALSE))
}

sbm_multi_level <- function(block_sizes1=c(2,2,2,2), block_sizes2=rep(25, times=8), p1, p2, p3){
    # generates two-level sbm of the given block sizes and probabilites
    # block_sizes1: higher level (number of lower level communities it includes, not vertices)
    # block_sizes2: lower_level
    # p1: probability of inner edges in the lower level of communities
    # p2: inner edges on the higher level, but outer edges on the lower
    # p3: outer edges on both
    n <- sum(block_sizes1)
    M <- matrix(nrow=n, ncol=n, p3)
    i <- 1
    for (j in block_sizes1){
        rg <- i:(i+j-1)
        M[rg,rg] <- p2
        i <- i+j
    }
    diag(M) <- p1
    
    n_vertices <- sum(block_sizes2)
    g_sbm <- sample_sbm(n_vertices, pref.matrix=M, block.sizes=block_sizes2)
}




sbm_multi_level_scores_table <- function(block_sizes1=c(2,2,2,2), block_sizes2=rep(25, times=8), 
                                         p1, p3, length.out=100){
    #p2 will vary, p1 and p3 are fixed
    # length.out: the number of values p2 will take (which will determine the "resolution" of the 
    # plot)
    
    membership_lower_level <- ground_truth_sbm(block_sizes2)
    block_membership <- ground_truth_sbm(block_sizes1)
    aux <- function (index, block_size) replicate(block_size, index) #used to compute the membership vector
    membership_upper_level <- unlist( mapply(aux,block_membership, block_sizes2, SIMPLIFY=FALSE) )
    
    lambda_seq <- seq(from=0, to=1, length.out=length.out)
    sample_graph <- function(lambda){
        g <- sbm_multi_level(block_sizes1, block_sizes2, p1, p3+lambda*(p1-p3), p3)
        scores_lower <- scoring_functions(g, membership_lower_level, type="global", weighted=FALSE)
        scores_upper <- scoring_functions(g, membership_upper_level, type="global", weighted=FALSE)
        list("lower"=scores_lower, "upper"=scores_upper)
    }
    all_scores <- pblapply(lambda_seq, sample_graph)
    scores_lower <- cbind(as.data.frame(do.call(rbind, lapply(all_scores, `[[`, 1))), "lambda"=lambda_seq, "level"="lower")
    scores_upper <- cbind(as.data.frame(do.call(rbind, lapply(all_scores, `[[`, 2))), "lambda"=lambda_seq, "level"="upper")

    rbind(scores_lower, scores_upper)
}

set.seed(1)
multi_level_scores_SBM <- sbm_multi_level_scores_table(block_sizes1=c(2,2,2,2), block_sizes2=rep(25, times=8), 
                                       p1=0.2, p3=.01, length.out=100)

save(multi_level_scores_SBM, file="multi_level_SBM_data.RData")


