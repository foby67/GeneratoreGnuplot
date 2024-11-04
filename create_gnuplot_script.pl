use strict;
use warnings;

# Nome del file CSV
my $csv_file = 'data.csv';

# Nome dello script gnuplot
my $gnuplot_script = 'plot_script.plt';

# Crea lo script gnuplot
open(my $fh, '>', $gnuplot_script) or die "Cannot open file '$gnuplot_script': $!";

# Scrivi il contenuto dello script gnuplot
print $fh <<'END_SCRIPT';
# Impostazioni di base per gnuplot
set terminal pngcairo size 800,600
set output "plot.png"
set datafile separator ","

# Impostazioni degli assi
set xlabel "Time Stamp"
set ylabel "Cycle Stamp"
set y2label "Machine Speed"
set y2tics

file = "sampling.csv"

# Plotta le colonne selezionate con assi separati
plot file using 1:2 title "Cycle Stamp" with lines axes x1y1, \
     file using 1:3 title "Machine Speed" with lines axes x1y2
END_SCRIPT

# Chiudi il file
close($fh);

print "Gnuplot script '$gnuplot_script' created successfully.\n";