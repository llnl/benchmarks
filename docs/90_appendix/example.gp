#!/usr/bin/gnuplot
set terminal pngcairo enhanced size 1024, 768 dashed font 'Helvetica,18'
set output "example-gnuplot.png"

set title "Gnuplot: APP Scaling on HAL 9000 Utilizing All Memory Circuits" font "serif,22"
set xlabel "Memory Percentage"
set ylabel "No. of Active Cameras"

set xrange [0:100]
set key left top

# set logscale x 2
# set logscale y 2

set format x "%.0f%%"

set grid
show grid

set datafile separator comma
set key autotitle columnheader

set style line 1 linetype 6 dashtype 1 linecolor rgb "#FF0000" linewidth 2 pointtype 6 pointsize 3
set style line 2 linetype 1 dashtype 2 linecolor rgb "#FF0000" linewidth 2

plot "example.csv" using 1:3 with linespoints linestyle 1
