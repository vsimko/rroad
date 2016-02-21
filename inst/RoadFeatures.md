# Road profile features
Viliam Simko  
February 20, 2016  
<!-- This file is generated from RoadFeatures.Rmd. Please edit that file -->


First, some some assumptions about the road and and our car:

```r
road_len_m <- 1000          # road length
speed_kmh <- 80             # car speed in km/h
sample_rate_hz <- 200       # sampling rate of a 3D accelerometer
speed_ms <- speed_kmh / 3.6 # car speed in m/s
sample_len <- round(speed_ms / sample_rate_hz, digits = 2) # sample size
num_samples <- round(road_len_m / sample_len) # how many samples we collected

print(sample_len)
```

```
## [1] 0.11
```

```r
print(num_samples)
```

```
## [1] 9091
```

First, we use some sample data obrained from a 3D-accelerometer.
We need to trim NA valued from the signal, because there might be gaps (NA values) and the interpolation doesn't work with NAs.


```r
signal <- data.frame(
  sampleid = seq_len(num_samples),
  dist_meters = seq(from = 0, to = road_len_m, by = sample_len)
#  accZ = rnorm(num_samples) * # random signal
#      sapply(rnorm(num_samples), function(x){ifelse(x > 1.8, 1, NA)}) # random gaps
)
load("../inst/example_data/2016_01_16_drive_k3535_acc_z.rda")
drive_k3535_acc_z$acc_z %>% head(num_samples) %>% scale -> signal$accZ

signal <- na.trim(signal)

plot(signal$dist_meters, signal$accZ, type = "o", pch = "+", cex = .5,
     main = "Some signal",
     xlab = "Distance traveled [m]",
     ylab = expression( paste("Z-acceleration [", m * s ^ -2, "]") ))
```

![](RoadFeatures_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

Now, we look at the gaps closely:

```r
signal %>% head(500) -> signal_head
plot(signal_head$dist_meters, signal_head$accZ,
     type = "o", xlab = NA, ylab = NA, pch = "+", cex = .5,
     main = paste("First", nrow(signal_head), "samples with gaps"))
```

![](RoadFeatures_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

We need to interpolate the values between the gaps:

```r
signal$accZ %>% na.approx(na.rm = FALSE) -> signal$accZ_approx

signal %>% head(500) -> signal_head
plot(signal_head$dist_meters, signal_head$accZ,
     type = "p", pch = "+", cex = .5, xlab = NA, ylab = NA,
     main = paste("First", nrow(signal_head), "samples interpolated"))

lines(signal_head$dist_meters, signal_head$accZ_approx,
       col = "red", pch = ".", xlab = NA, ylab = NA)
```

![](RoadFeatures_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

We can also analyze frequency content of the signal by using **Continuous Wavelet Transform (CWT)**. The following plot is called "scaleogram".

```r
library(biwavelet)
```

```
## biwavelet 0.19.0 loaded.
```

```r
w <- wt(cbind(signal$sampleid, signal$accZ_approx), dj = 1/2)
plot(w)
```

![](RoadFeatures_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

We can extract the CWT coeficients representing certaing frequency bands.
The `power.corr` matrix represents bias-correction version.

```r
nscales <- nrow(w$power.corr)
signal$cwt_mid  <- w$power.corr[floor(.5 * nscales),]
signal$cwt_high <- w$power.corr[floor(.2 * nscales),]
signal$cwt_low  <- w$power.corr[floor(.8 * nscales),]

plot(signal$cwt_high, type = "l")
lines(signal$cwt_mid, col = "blue", lw = 4)
lines(signal$cwt_low, col = "red", lw = 4)
```

![](RoadFeatures_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

Here, we compute moving average and root mean squared value:


```r
signal$accZ_approx %>% rollmean(k = 10, fill = NA) -> signal$rollmean10
signal$accZ_approx %>% rollmean(k = 20, fill = NA) -> signal$rollmean20

library(seewave)
signal$accZ_approx %>% rollapply(width = 20, fill = NA, FUN = rms) -> signal$rms20
```


```r
signal %>% head(3000) -> signal_head

plot(signal_head$dist_meters,
     signal_head$accZ_approx,
     type = "l", xlab = NA, ylab = NA,
     main = paste("First", nrow(signal_head), "samples interpolated"))

lines(signal_head$dist_meters, signal_head$rollmean10, col = "red", lw = 3)
lines(signal_head$dist_meters, signal_head$rollmean20, col = "blue", lw = 3)
lines(signal_head$dist_meters, signal_head$rms20, col = "green", lw = 3)
```

![](RoadFeatures_files/figure-html/unnamed-chunk-8-1.png)<!-- -->
