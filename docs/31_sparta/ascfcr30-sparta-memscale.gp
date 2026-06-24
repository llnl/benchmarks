#!/usr/bin/env gnuplot
set terminal pngcairo enhanced size 1024, 768 dashed font 'Helvetica,18'
set output "ascfcr30-sparta-memscale.png"

set title "SPARTA Single-node Memory Scaling" font "serif,22"
set xlabel "Memory Percentage"
set ylabel "Figure of Merit (Gparticle-steps/sec)"

set xrange [0:100]
set yrange [0:0.5]
set key left top

# set logscale x 2
# set logscale y 2

set format x "%.0f%%"

set grid
show grid

set datafile separator comma
set key autotitle columnheader

set style line 1 linetype 6 dashtype 1 linecolor rgb "#E69F00" linewidth 2 pointtype 6 pointsize 3
set style line 2 linetype 1 dashtype 2 linecolor rgb "#56B4E9" linewidth 2 pointtype 4 pointsize 3

plot "ascfcr30-sparta-memscale-cts2.csv" using ($7*100):5 with linespoints linestyle 1 title "CTS-2"
