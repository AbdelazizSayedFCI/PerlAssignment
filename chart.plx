#!/usr/local/bin/perl -w

use GD::Graph::lines;
use Date::Calc;
use CGI;
use DBConnect;


my $query = new CGI;
my $start = $query->param('start');
my $end = $query->param('end');
my $username = $query->param('username');
my $fullBuilds = $query->param('fullBuilds') ;
my $otherBuilds = $query->param('otherBuilds');
my $timeslot = $query->param('timeslot');

my $dbConnect = new DBConnect("build_assign", "root", "root");
my @list = $dbConnect->getAverageTime($start, $end, $username, $fullBuilds, $otherBuilds, $timeslot);

my @xvalues;
my @yvalues;
foreach $a (@list) 
{
   my ($time, $day ) = (split /,/,$a);
   push @xvalues, $day;
   push @yvalues, $time;
}
# Create a new bar graph

my $graph = new GD::Graph::lines(1000,300);

# Set the attributes for the graph

$graph->set(
    x_label           => 'Time Slot',          # No labels
    y_label           => 'Avg Build Time',
    title             => 'Average Build Time Graph',
    # Draw datasets in 'solid', 'dashed' and 'dotted-dashed' lines
    line_types  => [1],
    # Set the thickness of line
    line_width  => 2,
    # Set colors for datasets
    dclrs       => ['blue'],
    long_ticks  => 3	
);

# Add the legend to the graph
$graph->set_legend('Average Build Time Per Time Slot');

# Plot the graph and write it to STDOUT
my @data = (\@xvalues, \@yvalues);
print STDOUT $query->header(-type => 'image/png');
binmode STDOUT;                      # switch to binary mode
my $gd = $graph->plot( \@data );
print STDOUT $gd->png;

1;