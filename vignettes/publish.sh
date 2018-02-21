#!/bin/sh

# we run this script manually to generate new version of the vignette

cp RoadFeatures.Rmd gh-pages/index.Rmd
cd gh-pages

Rscript -e "library(knitr); knit('index.Rmd')"

git add .
git commit -a
git push

echo "appears shortly at: https://vsimko.github.io/rroad/"
