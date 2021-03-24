package DBConnect;
use DBI;	
use strict;
use warnings;

sub new 
{
   my $class = shift;
   my $self = {
      _database => shift,
      _userid  => shift,
      _pass       => shift,
   };    
   bless $self, $class;
   return $self;
}
sub insertLogsFromFile{
	my ($self, $filePath) = @_;
	my @splitFilePath = split /\\/,$filePath;
	my $username = $splitFilePath[$#splitFilePath];
	$username =~ s/.txt//;	
		
	my $driver = "mysql"; 
	my $dsn = "DBI:$driver:database=$self->{_database}";
	my $dbh = DBI->connect($dsn, $self->{_userid}, $self->{_pass} ) ;
		
	open(DATA, '<', $filePath) or die $!;
	
	while(<DATA>)
	{
		my @item_data = split /,/,$_;
		my $cd = (split /=/,$item_data[0])[1];
		my $ct = (split /=/,$item_data[1])[1];
		my $tt = (split /=/,$item_data[2])[1];
		my $w  = (split /=/,$item_data[3])[1] eq 'true'||0;
		my $np = (split /=/,$item_data[4])[1];
		my $r  = (split /=/,$item_data[5])[1] eq 'true'||0;
		my $a  = (split /=/,$item_data[6])[1] eq 'true'||0;
		my $ms = (split /=/,$item_data[7])[1];
		my $g  = (split /=/,$item_data[8])[1] eq 'true'||0;
		my $i  = (split /=/,$item_data[9])[1] eq 'true'||0;
		my $e  = (split /=/,$item_data[10])[1] eq 'true'||0;
		my $m  = (split /=/,$item_data[11])[1];
		my $s  = (split /=/,$item_data[12])[1] eq 'true'||0;
		my $p  = (split /=/,$item_data[13])[1];
		my $c  = (split /=/,$item_data[14])[1] eq 'true'||0;
		my $q  = (split /=/,$item_data[15])[1] eq 'true'||0;
		my $o  = (split /=/,$item_data[16])[1] eq 'true'||0;
		
		my $sth = $dbh->prepare("INSERT INTO build_info(username, cd, ct, tt, w, np, r, a, ms, g, i, e, m, s, p, c, q, o)values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");	
		$sth->execute("$username", $cd, $ct, $tt, $w , $np, $r, $a, $ms, $g, $i, $e, $m, $s, $p, $c, $q, $o);
		$sth->finish();	
			last;
	}
	close(DATA);
	return $filePath;
}
sub getAverageTime 
{
   my( $self ,$start ,$end, $username, $fullBuilds, $otherBuilds, $timeslot) = @_;
   
   	my $driver = "mysql"; 
	my $dsn = "DBI:$driver:database=$self->{_database}";
	my $dbh = DBI->connect($dsn, $self->{_userid}, $self->{_pass} ) ;
	my $quertStr = "";
	if($timeslot eq "days")
	{
		$quertStr = $quertStr . "SELECT avg(tt) as time ,cd as day FROM build_assign.build_info where cd between '$start' and '$end'";
	}
    elsif($timeslot eq "weeks")
	{
		$quertStr = $quertStr . "SELECT avg(tt), CONCAT('Week ', DATE_FORMAT(cd, '%V %Y'))  as week FROM build_assign.build_info where cd between '$start' and '$end'";
	}	
	elsif($timeslot eq "all")
	{
		$quertStr = $quertStr . "SELECT tt, Concat(cd,ct) FROM build_assign.build_info where cd between '$start' and '$end'";
	}	
	elsif($timeslot eq "hours")
	{
		$quertStr = $quertStr . "SELECT avg(tt), CONCAT(cd, ' ',Hour(ct), ':00')  as hour FROM build_assign.build_info where cd between '$start' and '$end'";
	}
	if($username)
	{
		$quertStr  = $quertStr . " and username = '$username' ";
	}			
	$quertStr  = $quertStr . " and a = '$fullBuilds' and o = '$otherBuilds' ";
	
	if($timeslot eq "days")
	{
		$quertStr  = $quertStr . "group by cd  ";		
	}
	elsif($timeslot eq "weeks")
	{
		$quertStr  = $quertStr . "group by week  ";		
	}	
	elsif($timeslot eq "hours")
	{
		$quertStr  = $quertStr . "group by hour  ";		
	}	
	$quertStr  = $quertStr . " limit 10";		
	#open(FH, '>', 'txt.txt') or die $!;
	#print FH "$quertStr";
	my $sth = $dbh->prepare($quertStr);
	$sth->execute() or die $DBI::errstr;
	
	my @list;
	while (my @row = $sth->fetchrow_array()) {
	   my ($time, $day ) = @row;
	   push @list, "$time, $day";
	}
	$sth->finish();
   return @list;
}

sub getMachniesData 
{
   my( $self ) = @_;
   
   	my $driver = "mysql"; 
	my $dsn = "DBI:$driver:database=$self->{_database}";
	my $dbh = DBI->connect($dsn, $self->{_userid}, $self->{_pass} ) ;
	my $quertStr = "SELECT m, count(*) as build, avg(tt) as time ,sum(np) as cores, sum(ms) as ram  FROM build_assign.build_info group by m;";

	my $sth = $dbh->prepare($quertStr);
	$sth->execute() or die $DBI::errstr;
	
	my @list;
	while (my @row = $sth->fetchrow_array()) {
	   my ($m, $b, $t, $p, $r ) = @row;
	   push @list, "$m, $b, $t, $p, $r";
	}
	$sth->finish();
   return @list;
}
1;