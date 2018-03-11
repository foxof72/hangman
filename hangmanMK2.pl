use warnings;
use strict;
use 5.010;
use Switch;
srand;

# need sudo cpan install Switch pacakge to use switch

print "Welcome to hangman!\n";

#Opens the file for reading
my $dictionary = "dictionary.txt";
open(my $fd, "<", $dictionary)
	or die "Can't open ", $dictionary;
my $word = "Default Value"; #default value is two words, impossible in a dictionary

my %theDictionary;

#gets a random line to retrieve the word from
my $counter = 0;
my $fdInit = $fd;
#gets the word on the random line from the file
while(my $line = <$fd>){
	chomp $line;
	$theDictionary{$counter} = $line;
	$counter = $counter + 1;
}
my $random = int(rand($counter));
$word = $theDictionary{$random};

$word = lc $word;
print "secret word is: ", $word, "\n";

#this preps the string for playing
my @wordArray = split("", $word);


# play the game
my $hasBeenGuessed = 1; #flag for checking if the character has been guessed already, defaulting to false (1)
my $hasBeenFound = 1; #flag for checking if the character has been found, meaning nothing gets added to the stick man, defaulting to false (1)
my $win = 0;
my @guessed;  #the values that have been guessed so far 
my @theWord; #this is the word as it is being guessed
my $misses = 0; #number of incorrect guesses
my @usFound; #this is an array that tracks your progress
# this loop sets arrays needed to play
for (my $var = 0; $var < scalar @wordArray; $var++) {
		$theWord[$var] = "_ ";
		$usFound[$var] = 0;
	}


#this loop runs the game itself
while ($win != scalar @theWord){
	print join("", @theWord);
	print "\n";
	print "You've guessed:\n";
	print join("", @guessed);
	print "\n";
	print "Guess a letter!";
	my $guess = <STDIN>;
	chomp($guess);
	$guess = lc $guess;
	if(length $guess != 1){
		my $len = length $guess;
		while ($len != 1) {
			print "Invalid input.  Try again.\n";
			print "Guess a letter!";
			$guess = <STDIN>;
			chomp($guess);
			$guess = lc $guess;
			$len = length $guess;
		}
	}
	for (my $j = 0; $j < scalar @guessed; $j++) {
			if($guessed[$j] eq $guess){
				$hasBeenGuessed = 0;
				last;
			}
		}
	if ($hasBeenGuessed == 1){
		for (my $i = 0; $i < scalar @wordArray; $i++) {
			if (($guess eq $wordArray[$i]) and ($hasBeenGuessed == 1)) {
				$theWord[$i] = $guess;
				$usFound[$i] = 1;
				$win = $usFound[$i] + $win;
				$hasBeenFound = 0;
			}
		}
		push @guessed, $guess;
	}
	if($hasBeenFound == 1){
		$misses = $misses + 1;
	}
	switch($misses){
		case 1{
			my $picture = `cat step1.txt`;
			print $picture, "\n";}
		case 2{my $picture = `cat step2.txt`;
			print $picture, "\n";}
		case 3{my $picture = `cat step3.txt`;
			print $picture, "\n";}
		case 4{my $picture = `cat step4.txt`;
			print $picture, "\n";}
		case 5{my $picture = `cat step5.txt`;
			print $picture, "\n";}
		case 6{my $picture = `cat step6.txt`;
			print $picture, "\n";
			print "You lose!\n";
			exit;}
	}
	$hasBeenGuessed = 1;
	$hasBeenFound = 1;
}

print "You win!!!\n";
