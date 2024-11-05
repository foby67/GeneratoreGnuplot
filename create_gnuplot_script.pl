use strict;
use warnings;

# Nome del file CSV
my $csv_file = 'sampling.csv';
open my $fhCSV, '<', $csv_file or die "Impossibile aprire '$csv_file': $!";
my $line = <$fhCSV>;
if ($line =~ /\{\"V/ ) { #la prima contiene le variabili
     $line = <$fhCSV>; #leggo la seconda linea, quella con i campi del CSV
}
chomp $line;  # Rimuove il carattere di nuova riga alla fine della riga
# print "$line\n";  # Stampa la riga o esegui altre operazioni su di essa

my @campiCSV = split /\,/, $line;
# print join("\n",@campiCSV),"\n";
my $labels = "";
for my $index (0 .. $#campiCSV) {
     my $i1 = $index+1;
     $labels .= "label$i1 = \"$campiCSV[$index]\"\n";
}
print $labels;

#creo la stringa per plottare
my $plots ="";
my $multiplots = "";
my $nplots = 0;
for(my $i = 2; $i <= $#campiCSV+1; $i++){
      $plots .=           "     file using ((\$1-offsZero)/divt):(\$$i) title label$i with lines lw 1 axes x1y1, \\\n";
      $multiplots .= "     plot file using ((\$1-offsZero)/divt):(\$$i) title label$i with lines lw 1 axes x1y1\n";
      $nplots++;
}
print $plots;


$line = <$fhCSV>; #leggo la prima linea dati
my @datiCSV = split /\,/, $line;
print "time stamp iniziale = $datiCSV[0]\n";
close($fhCSV);

# Nome dello script gnuplot
my $gnuplot_script = 'plot_script.plt';
my $counter = 1;

# Controlla se il file esiste e aggiunge un numero al nome fino a trovare un nome disponibile
while (-e $gnuplot_script) {
    $gnuplot_script = "plot_script_$counter.plt";
    $counter++;
}

# Crea lo script gnuplot
open(my $fh, '>', $gnuplot_script) or die "Cannot open file '$gnuplot_script': $!";

# Scrivi il contenuto dello script gnuplot
print $fh <<END_SCRIPT;
# Impostazioni di base per gnuplot
set autoscale
set terminal windows  size 1600,900 position 100,1

#---- se usi sfondo nero togli i commenti
# set border linecolor rgb "white"
# set grid linecolor rgb "white"
# set xtics textcolor rgb "white"
# set ytics textcolor rgb "white"
# set title textcolor rgb "white"
# set xlabel textcolor rgb "white"
# set ylabel textcolor rgb "white"
# set key textcolor rgb "white"

# Input file contains comma-separated values fields
set datafile separator ","

file = "$csv_file"

#impostazione legenda
#set key autotitle columnhead  #legge la legenda dalla prima riga
set key left top
set key box opaque
set key textcolor variable

# Impostazioni degli assi
set ylabel "Cycle Stamp"
set y2label ""
set y2tics

$labels

#----- se si vuole stampare su un png
#set term png  size 1600,950 background rgb 'black'
#set output "out.png"

# Calcola il primo valore di x automaticamente  (da ChatGPT)
stats file using 1 nooutput

offsZero = STATS_min + 0 #(da ChatGPT)
# offsZero = 0  #togliere il commento per visualizzare asse x con HH:MM:ss

divt= 1000
sta = -800
sto = 3500
# set xrange [sta:sto]

if (divt == 1000) {
     set xlabel "sec";
     if (offsZero == 0) { #imposta la visualizzazione dell'ora
          set xdata time #specifica che l'asse x è temporale.
          set timefmt "%s" # Indica che i dati in input sono in secondi
          set format x "%H:%M:%S"  # Formato di visualizzazione dell'asse x
          # set format x "%Y-%m-%d %H:%M:%S" # Formato di visualizzazione dell'asse x
     }
} 
if (divt == 1) {
     set xlabel "ms"
}


set lmargin at screen 0.05
set rmargin at screen 1-0.05
unset border
set grid

#  1 per multiplot
#  0 per singolo plot
multi = 1

#lc "color"  per colore linea
if (!multi) {
     plot \\
$plots
} else { #multiplot
     set multiplot layout $nplots,1
$multiplots
}
     
END_SCRIPT

# Chiudi il file
close($fh);

print "Gnuplot script '$gnuplot_script' created successfully.\n";