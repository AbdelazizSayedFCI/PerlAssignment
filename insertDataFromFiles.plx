#!/usr/local/bin/perl
use DBConnect;

my $dbConnect = new DBConnect("build_assign","root", "root");

$dbConnect->insertLogsFromFile('C:\Users\abdel\Downloads\PerlAssignment\log_files\egrhino.txt');
$dbConnect->insertLogsFromFile('C:\Users\abdel\Downloads\PerlAssignment\log_files\yycust.txt');




