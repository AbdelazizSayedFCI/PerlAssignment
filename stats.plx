#!/usr/local/bin/perl

use GD;
use CGI ;
use DBConnect;print "<tr><td>Machine Name</td><td>No. Of Build</td><td>Avg. Build Time</td><td>No. Of Cores</td><td>Ram Size</td></tr>";

#prepare the parameters
my $q = new CGI;
my $username = $q->param('username');
my $start = $q->param('start');
my $end = $q->param('end');
my $fullBuilds = $q->param('fullBuilds')  eq "on"||0;;
my $otherBuilds = $q->param('otherBuilds') eq 'on'||0;
my $timeslot = $q->param('timeslot');

my $dbConnect = new DBConnect("build_assign", "root", "root");
my @list = $dbConnect->getMachniesData();


print $q->header(-type => 'text/html');
print $q->start_html(-title => "DevOps!");

if ( $start && $end) 
{

    # Output the html for the image tag. This passes the data    
    print $q->h1("Avgerage Build Time Statistics Report");
    print $q->img({ src => "chart.plx?" . "username=$username&start=$start&end=$end&fullBuilds=$fullBuilds&otherBuilds=$otherBuilds&timeslot=$timeslot",width => 1000, height => 300 });
    print $q->br;
	print $q->br;	

} else 
{

    print $q->h1('Get your statistics here!');
}

# Print the form used to enter the dates
print $q->start_form({ method => 'post',
                       action => 'stats.plx' }),	

"Username: ",
$q->input({ type => 'text',	
		  name => 'username',
		  size => 10,
		  value => $username }),
" From: ",
$q->input({ type => 'date',
		  name => 'start',
		  size => 10,
		  value => $start }),
" To: ",
$q->input({ type => 'date',
		  name => 'end',
		  size => 10, 
		  value => $end }),		  

" Time Slot: ",
"<select name='timeslot' >",
"<option value='days'>--</option>",
"<option value='days'>Days</option>",
"<option value='hours'>Hours</option>",
"<option value='weeks'>Weeks</option>",
"<option value='all'>All</option>",
"</select> ",


$q->checkbox({ label=> 'Full Builds',
			   name=>'fullBuilds',
			   value=> "on"}),

$q->checkbox({ label=> 'Other Builds ',
			   name=>'otherBuilds',
			   value=> "on" }),

$q->input({ type => 'submit', value => 'Show Graph' }),
"<br>",
$q->end_form( );
print "<h1>Machines Data</h1>";
print "<table border=1>",
"<tr><th>Machine Name</th><th>No. Of Build</th><th>Avg. Build Time</th><th>No. Of Cores</th><th>Ram Size</th></tr>";
foreach $a (@list) 
{
	my ($m, $b, $t, $p, $r) = (split /,/,$a);
	print "<tr><td>$m</td><td>$b</td><td>$t</td><td>$p</td><td>$r</td></tr>";
}
"<tr><td>Machine Name</td><td>No. Of Build</td><td>Avg. Build Time</td><td>No. Of Cores</td><td>Ram Size</td></tr>",
"</table>";
$q->end_html( );
