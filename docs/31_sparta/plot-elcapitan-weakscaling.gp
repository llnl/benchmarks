#!/usr/bin/env gnuplot

# Plot SPARTA weak-scaling FOM from CSV.
# Output: elcapitan-weakscaling.png

set datafile separator comma
set encoding utf8
set terminal pngcairo size 1200,720 enhanced font 'DejaVu Sans,12'
set output 'elcapitan-weakscaling.png'

# Okabe-Ito blue, matching the existing eldo gnuplot files.
set style line 1 lc rgb '#0072B2' lw 2 pt 7 ps 0.9 dt 1
set style line 2 lc rgb '#6b7280' lw 1 dt 2

set title 'SPARTA Weak Scaling on El Capitan' font 'DejaVu Sans,18'
set xlabel 'Node Count'
set ylabel 'FOM/node (Gparticle-step/s/node)' textcolor rgb '#0b0b0b'

set border lc rgb '#374151'
set tics textcolor rgb '#374151'
set grid xtics ytics lc rgb '#d1d5db' lw 1
set key off

set logscale x 8
set xrange [1:4097]
set xtics ('1' 1, '8' 8, '64' 64, '512' 512, '4096' 4096)
set mxtics 1
set format x '%g'

set format y '%.2f'
set yrange [7.6:9.3]

set lmargin 12
set rmargin 9
set bmargin 5
set tmargin 5

baseline_fom = 8.95167051
set arrow 1 from graph 0, first baseline_fom to graph 1, first baseline_fom nohead back ls 2
set style textbox opaque fc rgb '#ffffff' noborder margins 0.6,0.25
set label 3 sprintf('Node 1 FOM = %.2f', baseline_fom) at graph 0.58, first baseline_fom center front boxed tc rgb '#374151'

set label 1 '100.0%' at graph 0, first 8.95167051 left offset char 0.3,1.1 tc rgb '#374151'
set label 2 '88.6%' at graph 1, first 7.93476074 right offset char -0.3,-1.4 tc rgb '#374151'

plot 'elcapitan-weakscaling.csv' every ::1 using 1:3 with linespoints ls 1 title 'FOM per node', \
     '' every ::1 using (($1 != 1 && $1 != 4096 && $0 % 2 == 0) ? $1 : 1/0):3:(sprintf('%.1f%%', $4 * 100.0)) with labels center offset char 0,1.1 tc rgb '#374151' notitle, \
     '' every ::1 using (($1 != 1 && $1 != 4096 && $0 % 2 == 1) ? $1 : 1/0):3:(sprintf('%.1f%%', $4 * 100.0)) with labels center offset char 0,-1.4 tc rgb '#374151' notitle
