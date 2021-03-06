#==============================================================================
# 04-model-first-stage.R
# Purpose: fitting spatial following model
# Runtime: ~18 hours on NYU HPC (far more in BR)
# Author: Pablo Barbera
# Adaptation: Camila Lainetti de Morais
#==============================================================================

# setwd('your_location')
source('auxiliary_functions/functions.R')

matrixfile <- 'data/output/adj-matrix-tcc-filter-br.rdata'
outputfile <- 'data/temp/stan-fit-tcc-filter-br.rdata'
samplesfile <- 'data/output/samples-tcc-filter-br.rdata'
resultsfile <- 'data/output/results-elites-tcc-filter-br.rdata'
country <- 'TCC'

# loading data
load(matrixfile)

## starting values for elites (for identification purposes)
tcc <- read.csv("data/output/elites-data-tcc-2.csv", sep=";")

parties <- merge(
  data.frame(screen_name = colnames(y), stringsAsFactors=F),
  tcc[,c("simple_screen_name", "simple_class")], sort=FALSE, all.x=TRUE)$simple_class

start.phi <- rep(0, length(parties))
start.phi[parties == 'F'] <- -1
start.phi[parties == 'A'] <- 1

J <- dim(y)[1]

# choosing a sample of 10,000 "informative" users who follow 10 or more
# politicians, and then subsetting politicians followed by >200 of these

if (J>10000){
  J <- 10000
  inform <- which(rowSums(y)>10)
  set.seed(12345)
  subset.i <- sample(inform, J)
  y <- y[subset.i, ]
  start.phi <- start.phi[which(colSums(y)>200)]
  y <- y[,which(colSums(y)>200)]
}

write.csv(y@Dimnames[[2]], file='../../../Resultados_fase_2/') # getting the influencers analised

#y_matrix <- as(y, "matrix")
#write.csv(y_matrix, file='../../../Resultados_fase_2/adj_matrix_smaller.csv')

## data for model
J <- dim(y)[1]
K <- dim(y)[2]
N <- J * K
jj <- rep(1:J, times=K)
kk <- rep(1:K, each=J)

stan.data <- list(J=J, K=K, N=N, jj=jj, kk=kk, y=c(as.matrix(y)))

## rest of starting values
colK <- colSums(y) # followers sum
rowJ <- rowSums(y) # influencers sum
normalize <- function(x){ (x-mean(x))/sd(x) }

inits <- 
  rep(
    list(
      list(
        alpha=normalize(log(colK+0.0001)), # j popularity
        sigma_alpha=1,
        
        beta=normalize(log(rowJ+0.0001)), # i interest
        mu_beta=0,
        sigma_beta=1,
        
        theta=rnorm(J), # i ideal point
        
        phi=start.phi, # j ideal point
        mu_phi=0,
        sigma_phi=1,
        
        gamma=abs(rnorm(1)) # normalization constant
      )
    )
    ,2)


library(rstan)

stan.code <- '
data {
int<lower=1> J; // number of twitter users
int<lower=1> K; // number of elite twitter accounts
int<lower=1> N; // N = J x K
int<lower=1,upper=J> jj[N]; // twitter user for observation n
int<lower=1,upper=K> kk[N]; // elite account for observation n
int<lower=0,upper=1> y[N]; // dummy if user i follows elite j
}
parameters {
vector[K] alpha; // j popularity
vector[K] phi; // j ideal point
vector[J] beta; // i interest
vector[J] theta; // i ideal point
real mu_beta; // avg i interest (0)
real<lower=0.1> sigma_beta; // std deviation i interest(1)
real mu_phi; // avg ideal point j (0)
real<lower=0.1> sigma_phi; // std deviation ideal point j (1)
real<lower=0.1> sigma_alpha; // std deviation popularity j (1)
real gamma;
}
model {
alpha ~ normal(0, sigma_alpha);
beta ~ normal(mu_beta, sigma_beta);
phi ~ normal(mu_phi, sigma_phi);
theta ~ normal(0, 1); 
for (n in 1:N)
y[n] ~ bernoulli_logit( alpha[kk[n]] + beta[jj[n]] - 
gamma * square( theta[jj[n]] - phi[kk[n]] ) );
}
'
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# parameters for Stan model
n.iter <- 500 # chain interactions (2000 default)
n.warmup <- 100 # chain warmup (1000 default)
thin <- 1

## compiling model
stan.fit <- stan(model_code=stan.code, 
                 data = stan.data,
                 init=inits,
                 iter=n.iter, 
                 warmup=n.warmup, 
                 chains=1, 
                 thin=1)

## running model
stan.fit <- stan(fit=stan.fit, 
                 data = stan.data, 
                 iter=n.iter, 
                 warmup=n.warmup, 
                 thin=thin, 
                 init=inits,
                 chains=2)

save(stan.fit, file=outputfile)

## extracting and saving samples
samples <- extract(stan.fit, pars=c("alpha", "phi", "gamma", "mu_beta",
                                    "sigma_beta", "sigma_alpha"))
save(samples, file=samplesfile)

## saving estimates
results <- data.frame(
   phi = apply(samples$phi, 2, mean),
   phi.sd = apply(samples$phi, 2, sd),
   alpha = apply(samples$alpha, 2, mean),
   alpha.sd = apply(samples$alpha, 2, sd),
   stringsAsFactors=F)
 
save(results, file=resultsfile)


