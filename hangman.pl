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
#print $count, "\n";
#gets a random line to retrieve the word from
my $counter = 0;
my $fdInit = $fd;
#gets the word on the random line from the file
while($word eq "Default Value"){
	my $randomLine = int(rand($count));
	#print "Random line is: ", $randomLine, "\n";
	while (<$fd> and ($word eq "Default Value")){
		#print "counter: ", $counter, , "\n";
		if ($counter == $randomLine) {
			$word = <$fd>;
		}
		$counter++;
	}
}
chomp $word;
print "secret word is: ", $word, "\n";

#this preps the string for playing
my @wordArray = split("", $word);

#print $wordArray[0], "\n";


# play the game
my $win = 1;
#print "length: ", $len;
while ($win != 0){
	for (my $var = 0; $var < scalar @wordArray; $var++) {
		print "_ ";
	}
	print "\n";
	$win = 0;
}
