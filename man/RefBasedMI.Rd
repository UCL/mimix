% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Runmimix.R
\name{RefBasedMI}
\alias{RefBasedMI}
\title{Main function for performing reference-based multiple imputation of longitudinal data}
\usage{
RefBasedMI(
  data,
  covar = NULL,
  depvar,
  treatvar,
  idvar,
  timevar,
  method = NULL,
  reference = NULL,
  methodvar = NULL,
  referencevar = NULL,
  K0 = 1,
  K1 = 1,
  delta = NULL,
  dlag = NULL,
  M = 1,
  seed = 101,
  prior = "jeffreys",
  burnin = 1000,
  bbetween = NULL,
  mle = FALSE
)
}
\arguments{
\item{data}{Dataset in long format}

\item{covar}{Covariates - baseline.  Must be complete (no missing values), enclose in quotes.}

\item{depvar}{Outcome variable}

\item{treatvar}{Treatment group, can be numeric or character}

\item{idvar}{Participant identifier.}

\item{timevar}{Time point for repeated measure}

\item{method}{Reference-based imputation method: must be "J2R", "CR", "CIR","MAR", "Causal" or "LMCF"}

\item{reference}{Reference group for "J2R", "CIR", "CR" methods , can be numeric or string}

\item{methodvar}{column in data-set specifying individual method}

\item{referencevar}{column in data-set specifying reference group as for individual method,}

\item{K0}{Causal constant for use with Causal method}

\item{K1}{exponential decaying Causal constant for use with Causal method}

\item{delta}{vector of delta values to add onto imputed values (non-mandatory) (a's in Five_Macros user guide),length as number of time points}

\item{dlag}{vector of delta values to add onto imputed values (non-mandatory) (b's in Five_Macros use guide),length as number of time points}

\item{M}{Number of imputations to be created}

\item{seed}{Seed value. Specify this so that a new run of the command will give the same imputed values.}

\item{prior}{prior when fitting multivariate normal distributions. It can be one of "jeffreys" (default), "uniform" or "ridge"}

\item{burnin}{Number of burn-in iterations when fitting multivariate normal distributions.}

\item{bbetween}{Number of iterations between imputed data sets when fitting multivariate normal distributions.}

\item{mle}{logical option - not recommended !}
}
\value{
The M imputed data sets are output concatenated as one large dataframe in long format

appended to the original unimputed data-set
}
\description{
main wrapper for running RefBasedMI (previously mimix)
}
\details{
The program works through the following steps
\itemize{
\item {1.} {set up a summary table based on treatment arm and missing data pattern
(i.e. which timepoints are unobserved) }
\item {2.} {Fit a multivariate normal distribution to each treatment sarm using MCMC methods in package norm2}
\item {3.} {Impute all interim missing values  under a MAR assumption, looping over treatments and patterns}
\item {4.} {Impute post-discontinuation missing values under the user-specified assumption,
looping over treatments and patterns (and over methodvar and referncevar if specified)}
\item {5.} {Perform delta-adjustment if specified}
\item {6.} {Repeat steps 2-5 M times and form into a single data frame}
}

The baseline value of the outcome could be handed as an outcome, but this would allow a treatment effect at baseline

We instead  recommend handling it as a covariate

The program is based on Suzie Cro's Stata program mimix

The user can use the as.mids() function in the mice package to convert the output data to mids data type and hence

to perform analysis using Rubin's rules.
}
\examples{
\dontrun{
#performing jump to reference with treatment reference arm 1 on asthma trial data
mimixout<-RefBasedMI(data=asthma,covar=c("base"),depvar=fev,treatvar=treat,idvar=id,timevar=time,
 method="J2R", reference=1,M=5,seed=54321)
library(mice)
#Fitting regression model to find treatment effects using Rubin's rules by
#    treating output data frame as.mids() object
fit<-with(data= as.mids(subset(mimixout[[2]],time==12)), lm(fev~treat+base))
summary(pool(fit))
RefBasedMI(data=acupuncture,covar= c("head_base"),depvar=head,treatvar=treat,idvar=id,
 timevar=time,method="CIR",reference=1,M=5,seed=54321,
  prior=jeffreys,burnin=1000)
}
}
