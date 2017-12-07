#!/usr/bin/env perl 

use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;
use 5.10.1;

sub main;
sub words;
sub printDiff;
sub lcsLength;
sub compareWords;
sub maximum;

my @deleteWord = ();
my @addWord = ();

#main() is the main sub that this program runs from. 
sub main{
#takes two file and saves them in the @argv array
my ($file, $file1) = @ARGV;
#opens and reads the files
open (my $fh,  '<', $file) or die "File operation Failed: $!"; 
open (my $fh1, '<', $file1) or die "File operation Failed: $!"; 

#if less than 2 arguments are entered on nothing entered returns an error and exits
if(@ARGV < 2){
	 die "You have not selected 2 files.... ABORTING!\n";
}
#if the files supplied are not of text format the program will abort
unless (-T $ARGV[0] || $ARGV[1]){
	die "The file you have chosen is not a text file: Exiting....";
}
#initailizes the arrays we will use to store the data
my @arrayFile1 = ();
my @arrayFile2 = ();
#initializes two counters to begin at zero
my ($arrayCounter1, $arrayCounter2) = (0,0);
#set the 1st indexes of the array to null as the LCS algorithm starts from 1 tried to change the algo around but ye.
$arrayFile1[0] = "";
$arrayFile2[0] = "";

#loops through the files and mutates the data with the regular expressions and then stores in an array
while (<$fh>){
	#changes all capitals to lower case
	$arrayFile1[$arrayCounter1] =~ tr/[A-Z]/[a-z]/;
	#removes all html tags
	$arrayFile1[$arrayCounter1] =~ s/[<]{1}[\/]?[a-z]{1,}[>]/  /g;
	#removes puntuation and replaces with one !
	$arrayFile1[$arrayCounter1] =~ s/[#-?;:,'"&*()~\.`^%]{1,}/ ! /g;	
	$arrayCounter1++;
    push(@arrayFile1, $_);
}

while(<$fh1>){

	$arrayFile2[$arrayCounter2] =~ tr/A-Z/a-z/;
	$arrayFile2[$arrayCounter2] =~ s/[<]{1}[\/]?[a-z]{1,}[>]/  /g;
	$arrayFile2[$arrayCounter2] =~ s/[#-?;:,'"&*()~\.`^%]{1,}/ ! /g;
	$arrayCounter2++;
    push(@arrayFile2, $_);

}
	#sends the data to words sub and then the returned data is overwritten into itself
	@arrayFile1 = words(\@arrayFile1);
	@arrayFile2 = words(\@arrayFile2);
	#this counts the number of indexes in the arrays
    my $i = scalar(@arrayFile1)-1;
    my $j = scalar(@arrayFile2)-1;
   	#send the files to the lcs algoritm 
    my @lengthLCS = lcsLength(\@arrayFile1, \@arrayFile2, $i, $j);

    printDiff(\@lengthLCS, \@arrayFile1, \@arrayFile2, $i, $j);
 	my $wordDiffer = compareWords;

 	print "\n\n$wordDiffer words differ from $file and $file1\n\n";
 
    close $fh;
    close $fh1;
}
#this sub takes an array as a parameter then splits in by words and return an array of words to the calling main
sub words{

	my @array = @{$_[0]};
	my @arrayWords1 = ();
	$arrayWords1[0] = "";
	my $wordinFile = join "\n", @array;
	my @arrayWords = $wordinFile =~ /\w+/g;
    	
    	foreach my $everyWord (@arrayWords) {
    		#print $everyWord."\n";
    		push(@arrayWords1, $everyWord);
    	}
    	return @arrayWords1;
    }
# Pseudocode http://en.wikipedia.org/wiki/Longest_common_subsequence_problem#Print_the_diff
 sub printDiff{       
    my @c = @{$_[0]};
    my @X = @{$_[1]};
    my @Y = @{$_[2]};
    my $i = $_[3];
    my $j  = $_[4];

        if ($i > 0 and $j > 0  and ($X[$i] eq $Y[$j])) {
            
            printDiff(\@c, \@X, \@Y, $i-1, $j-1);
            
        }
	    
            elsif($j > 0 and ($i == 0 or $c[$i][$j-1] ge  $c[$i-1][$j])){
                     
                    printDiff(\@c, \@X, \@Y, $i, $j-1);
                    push @addWord, "$Y[$j]";
         
            }
     
            elsif ($i > 0 and ($j == 0 or $c[$i][$j-1] < $c[$i-1][$j])){
               
                printDiff(\@c, \@X, \@Y, $i-1, $j);
                 push @deleteWord, "$X[$i]";
               
            }
        else{
    } 
}
    #this sub does a comparison between the words that need to be added/deleted/changed from the 
    #lcs algorithm it then returns the number of words that are different between the files. 
	sub compareWords{
		
    	my $count = 0;
    	
    	for (my $i = 0; $i < $#deleteWord; $i++){
    		for(my $j = $i; $j < $#addWord; $j++){
    			if($deleteWord[$i] ne $addWord[$j]){
    			
    				$count++;
    				last;
    			}
    		}
    	}	
    	return $count;
	}

	# Ref: http://en.wikipedia.org/wiki/Longest_common_subsequence_problem#Computing_the_length_of_the_LCS
    sub lcsLength{
        
        my @X = $_[0];
        my @Y = $_[1];
        my $m = $_[2]; 
        my $n = $_[3]; 
        
        my @c = ();
        
        for (my $i = 0; $i <= $m; $i++)
        {
            $c[$i][0] = 0;
        }
        
         for (my $j = 0; $j<= $n; $j++)
        {
            $c[0][$j] = 0;
        }
    
        for (my $i = 1; $i < $m; $i++)
        {
            
            for (my $j = 1; $j < $n; $j++)
            {
        
                if (@{$X[0]}[$i] eq @{$Y[0]}[$j])
                {
                    $c[$i][$j] = ($c[$i-1][$j-1]) +1;
                }
            
                else
                {
                    $c[$i][$j] = maximum($c[$i][$j-1], $c[$i-1][$j]);
                }
            }
        }

        return @c;     
}
#this is a maximum sub that take a number and tests it against another number
sub maximum {
            
    my ($maximum, @numArray) = @_;
            
        foreach my $numbers (@numArray) {
                
            $maximum = $numbers if $numbers > $maximum;
            
        } 
           
     return $maximum;
}

main();

=pod 
=begin 

=head1 partC.pl 
 
This scipt compares two text files and reports back the difference in words.

The report will consist of:

*** How many words differ in each file. 
*** The program will also use some regular expression to remove html tags such as <div> <html> etc. 
*** This program will also remove punctuations and replace them with !.  


 
=head1 Program Summary 

sub main;

This is the main sub. Its purpose it two take in two arguments and parameters test them for text files and then 
systematically alter them via regex and then calling on the preceeding subs to do some further mutations and analysis.  
sub words;

This sub gets and array of sentences then removes each word and places it in its own array index. 

sub printDiff;
Pseudocode http://en.wikipedia.org/wiki/Longest_common_subsequence_problem#Print_the_diff

sub lcsLength;
Ref: http://en.wikipedia.org/wiki/Longest_common_subsequence_problem#Computing_the_length_of_the_LCS

sub maximum;
Finds a maximum number and returns the value. 

sub compareWords;

This sub does a comparison between the words that need to be added/deleted/changed from the 
lcs algorithm it then returns the number of words that are different between the files. 

=head2 How to use

1. Open terminal
2. Locate the directory where the program is stored.
3. To run the program type in the following ignoring < >
		
		./<program name including .pl> <file1> <file2>

Note that if the files do no live in the same directory just put the directory location:
eg: home/document/file1.txt

=head2 Student name and number

Name: John Lakkis
Student Number: s3018841

=cut
