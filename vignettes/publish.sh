#!/bin/sh

cp RoadFeatures.Rmd gh-pages/index.Rmd
cd gh-pages

Rscript -e "library(knitr); knit('index.Rmd')"

git add .
git commit -a
git push
