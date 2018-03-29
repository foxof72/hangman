use warnings;
use 5.010;
srand;

print "Welcome to hangman!\n";

#Opens the file for reading
my $dictionary = "testDictionary.txt";
open(my $fd, "<", $dictionary)
	or die "Can't open ", $dictionary;
my $word = "Default Value"; #default value is two words, impossible in a dictionary

$count = `wc -l < $dictionary`;
die "wc failed: $?" if $?;
chomp($count);

#gets a random line to retrieve the word from
my $counter = 0;
my $fdInit = $fd;
#gets the word on the random line from the file
while($word eq "Default Value"){
	my $randomLine = int(rand($count));
	while (<$fd> and ($word eq "Default Value")){
		if ($counter == $randomLine) {
			$word = <$fd>;
		}
		$counter++;
	}
}
chomp $word;
$word = lc $word;
print "secret word is: ", $word, "\n";

#this preps the string for playing
my @wordArray = split("", $word);


# play the game
my $win = 0;
my @guessed;  #the values that have been guessed so far 
my @theWord; #this is the word as it is being guessed
my @usFound; #this is an array that tracks your progress
my $hasBeenGuessed = 0; #flag for if a guess has already been guessed
# this loop sets arrays needed to play
for (my $var = 0; $var < scalar @wordArray; $var++) {
		@theWord[$var] = "_ ";
		@usFound[$var] = 0;
	}
#print "length: ", $len;

#this loop runs the game itself
#print "usFound: ", join("", @usFound), "\n";
#print "incoming parameter: ", scalar @theWord, "\n";
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
	for (my $i = 0; $i < scalar @wordArray; $i++) {
		#print "current letter: ", @wordArray[$i], "\n";
		for (my $j = 0; $j < scalar @guessed; $j++) {
			if(@guessed[$j] eq $j){
				$hasBeenGuessed = 1;
				last;
			}
		}
		# print "hasBeenGuessed "
		if (($guess eq @wordArray[$i]) and ($hasBeenGuessed != 0)) {
			@theWord[$i] = $guess;
			@usFound[$i] = 1;
			$win = @usFound[$i] + $win;
		}
		$hasBeenGuessed = 1;
	}
	push @guessed, $guess;
	#print "win value: ", $win, "\n";
}
print "You win!!!";
