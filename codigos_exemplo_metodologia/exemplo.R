setwd('3 - Pessoal/TCC/Códigos/Exemplo/')

library('ltm')
#response <- Abortion[sample(1:nrow(Abortion), 300,
#                           replace=FALSE),] # Pesquisa Britanica
                                             # Nossa amostra terá só 20 observações por questões
                                             # de tempo de rodagem

response <- Abortion # usando todas as observacoes

library(rstan)
#rstan_options(auto_write = TRUE)            # salva versões do programa compilado 
                                            # pelo Stan ao HD para não precisar 
                                            # ser recompilado
options(mc.cores = parallel::detectCores()) # habilita rodagem em paralelo

# data
n <- nrow(response) # quantidade de observacoes
k <- 4              # numero de itens

stan.data <- list(N=n,
                  K=k,
                  y1=response$'Item 1',
                  y2=response$'Item 2',
                  y3=response$'Item 3',
                  y4=response$'Item 4'
)

stan.code <- '
data {
int<lower=1> N;                   // quantidade de entrevistados
int<lower=1> K;                   // quantidade de itens
int<lower=0,upper=1> y1[N];       // variaveis de observacao de itens
int<lower=0,upper=1> y2[N];       // variaveis de observacao de itens
int<lower=0,upper=1> y3[N];       // variaveis de observacao de itens
int<lower=0,upper=1> y4[N];       // variaveis de observacao de itens
}
parameters {
vector[N] theta;               // permissividade ao aborto do entrevistado i
real<lower=0> beta[K];         // dificuldade em ser favoravel ao item k
}
model {
// distribuicoes a priori
theta ~ normal(0,1000);
beta ~ normal(0,1000);

// itens
y1 ~ bernoulli_logit(theta - beta[1]);
y2 ~ bernoulli_logit(theta - beta[2]);
y3 ~ bernoulli_logit(theta - beta[3]);
y4 ~ bernoulli_logit(theta - beta[4]);
}
'

# parametros do modelo Stan
n.iter <- 2000    # iterações por cadeia (2000 default)

## compilacao do modelo
stan.model <- stan(model_code = stan.code, # código em stan
                   data = stan.data,       # data
                   iter = n.iter,          # iteracoes
                   chains = 4              # qtd. cadeias markov
              )

output <- extract(stan.model, permuted = TRUE)
write.csv(output, file='draws.csv')
#save(stan.model, file='model_exemplo_todos_02_08.Rdata')
#save(output, file='output_exemplo_todos_02_08.Rdata')
matrix_of_draws <- as.matrix(stan.model)

# Analises
traceplot(stan.model, pars = c("theta[10]", "theta[20]", "theta[30]", "theta[40]"), inc_warmup = T, nrow = 10) # plots das estimacoes
traceplot(stan.model, pars = "beta", inc_warmup = T, nrow = 10)
traceplot(stan.model, pars = "theta", inc_warmup = T, nrow = 10)

print(stan.model, pars=c("theta",       # resumo das dist. a posteriori dos parametros
                        "beta",
                        "lp__"), 
                        probs=c(.25,.5,.75,.9))

######THETA
# Estimacao e Plot das Distribuicoes a posteriori (de theta)
INDEX <- 1:n                                      # fazemos um index das n observacoes
INDEX <- INDEX[order(apply(output$theta,2,mean))] # ordenamos de acordo com o theta

# pegamos a media das distribuicoes a posteriori, 
# baseado na orden crescente da média
POSTERIORS <- apply(output$theta,2,mean)[INDEX]

# distribuicao
hist(POSTERIORS,
     breaks=5, 
     main="Histograma da Média das Permissividades Theta em Relação ao Aborto",
     xlab="Permissividade Theta",
     ylab="Frequência")

# fazemos o plot
par(mar=c(4,8,2,2), font=1, font.lab=1, cex=0.8)
plot(POSTERIORS, 1:n, xlim=c(-3.5,3.5), axes=1,
     xlab="Estimacao (Media da Distribuicao a Posteriori)", 
     main="Permissividade Theta em Relação ao Aborto", 
     ylab="Entrevistados", las=1)

# Limites a direita e a esquerda das distribuicoes a posteriori
lb <- apply(output$theta,2,quantile,.025)[INDEX]
ub <- apply(output$theta,2,quantile,.975)[INDEX]

# looping em cada estimacao e 
# plot da linha do intervalo de 95% de confianca
for(i in 1:n){
  lines(c(lb[i], ub[i]), c(i,i), col="#820303", lwd=2)
}

# adicionando pontos em cima desses intervalos
points(POSTERIORS, 1:n, col="#820303", bg="#f7f2f2", cex=1, pch=21)

# adicionando axis ao lado direito do plot com a identificacao dos entrevistados, 
# respeitando a ordem das medias
axis(side=2, at=1:n, labels=as.character(rownames(response))[INDEX], las=1)



######BETAS
# Estimacao e Plot das Distribuicoes a posteriori (dos betas)

NAMES <-c("Item 1", 
          "Item 2",
          "Item 3",
          "Item 4")

INDEX <- 1:k
#INDEX  <- INDEX[order(apply(output$beta,2,mean))]
BETA <- apply(output$beta,2,mean)[INDEX]
LB.BETA <- apply(output$beta,2,quantile,.025)[INDEX]
UB.BETA <- apply(output$beta,2,quantile,.975)[INDEX]

par(
  family = "sans",
  oma = c(0,0,0,0),
  mar = c(2,5,1,1),
  mfrow= c(1,1)
)

plot(NULL,# create empty plot
     xlim = c(-2,2), # set xlim by guessing
     ylim = c(1,4), # set ylim by the number of variables
     axes = F, xlab = NA, ylab = NA,
     main="Parâmetros de Dificuldade dos Itens", cex=0.4)  # turn off axes and labels   


for (j in order(BETA)){
  lines(c(LB.BETA[j], UB.BETA[j]),c(j,j),col="#600202", lwd=1)
  points(c(BETA[j], BETA[j]),c(j,j),bg=c("#f7f2f2"), col="#600202",  cex=.6, pch=5 )
}


lab=seq(-2,2,by=2)
axis(1, at=lab, labels=lab,cex.axis=.8)

axis(side=2, at=1:4, labels=NAMES[INDEX], las=2, cex=0.8)
mtext(side = 1, "Parametros de Dificuldade dos Itens", main='Dificuldade', line=2.5, cex=0.8)

