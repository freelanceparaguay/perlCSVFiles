#!/usr/bin/perl
##################################################
# Autor: http://otroblogdetecnologias.blogspot.com 
#	 Juan Carlos Miranda juancarlosmiranda81@gmail.com
# Version: 1.0
#
# The author is not liable for damages caused by the use Script
#
# Script objetives:
#======================
# This script work with text in CSV format.
# Take data from a CSV file and put it into other file.
# Sort and eliminate repeated data.
#=======================
#WARNING!!!!
#=======================
# * Put the specials authorizations chmod 755 al script.
#   Unix commands : sort, uniq, rm
##################################################

##################################################
use strict;
use warnings;
use Getopt::Long; #get parameters
use Text::CSV;
##################################################

##################################################
## BEGIN MAIN
##################################################
my $fileName = "./read1.csv";
# Read parameters from CLI rh_params variable
my $get_parameters = {};
GetOptions($get_parameters,
  'a:s',
  'help',
);
 
# help parameter
$get_parameters->{help} && print_help( 0 );

  if( defined $get_parameters->{a}) {
    if(!($get_parameters->{a} eq "")){
#####################################################################  	
	$fileName=$get_parameters->{a};
	#si llego hasta aca es porque el parametro del archivo esta bien
	open FILE1,$fileName or die "Fault opening fail: $fileName -> $!";
	#si llego hasta aca es porque el archivo es real
	###################################	

	print "--procesar ";	
	print "--ordenar ";		
	print "--Copy from original file ";	
	copyFile($fileName,"temporal.csv");
	print "--Sorting... ";	
	sortFileReport("temporal.csv");
	print "--Creating final report";	
	putHeaderReport("temporal.csv","finalReport.csv");
	print "--Complete";	
	###################################	
	close FILE1;	
#####################################################################  	      
    }else{
      print_help( 1 );
    }
  }else{
    print_help( 1 );
  }



##################################################
## END MAIN
##################################################

##################################################
## PROCEDURES AND FUNCTIONS
##################################################
sub print_help {
    my $exit_status = shift;
    print <<"END"
    Use: $0 [-a file.csv]
    ...help
          -a     processes only the specified file
          -help Print this
END
;

    exit $exit_status;
}


sub copyFile{
	my ($fileName1,$fileName2)=@_;
####################################################################################################
	open (my $fh,"<",$fileName1) or die "$fileName: $!";
	open(FILEREPORT,">",$fileName2) or die "Can not open the file: $fileName2 -> $!";					
	my $csv = Text::CSV->new ({
		binary    => 1, # Allow special character. Always set this
		auto_diag => 1, # Report irregularities immediately
	});	
	#set headers names
	$csv->column_names (qw ("Date" "Systolic" "Diastolic" "Pulse"));		
	#print a temporal file	with the results
	my $row = $csv->getline ($fh);
	while ($row = $csv->getline ($fh)) {
		my $pulseP=@$row[1]-@$row[2];
#			Calculus MAP = [(2 x diastolic)+systolic] / 3
		my $MAP=(2 * @$row[2]+@$row[1])/3;
#		        print FILEREPORT "Systolic,Diastolic,Pulse   ,Weight,Mean Arterial Pressure,Pulse Pressure,My Item,Date    ,Note\n";					
		print FILEREPORT "@$row[1],@$row[2],@$row[3],0,$MAP,$pulseP,0,@$row[0], \n";
	}
	close (FILEREPORT);
	close $fh;
####################################################################################################
}


##################################################
# sort file and eliminate repeated
##################################################
sub sortFileReport {
	my ($arFinal)=@_;
	print "\n Report sort=>".$arFinal."\n";
	system ("sort -k 8 ".$arFinal." > ".$arFinal."2");
	system ("uniq ".$arFinal."2"." > ".$arFinal);	
	system ("rm -f ".$arFinal."2");	
}

##################################################
# put header or columns names
##################################################
sub putHeaderReport {
	my ($fileData, $fileFinal)=@_;
	open(FILEDATA,"<",$fileData) or die "Can not open the file: $fileData -> $!";		
	open(FILEFINAL,">",$fileFinal) or die "Can not open the file: $fileFinal -> $!";			

	print FILEFINAL"Systolic,Diastolic,Pulse,Weight,Mean Arterial Pressure,Pulse Pressure,My Item,Date,Note\n";			
	while(<FILEDATA>){
		print FILEFINAL $_;
	}		
	close FILEDATA;
	close FILEFINAL;
}