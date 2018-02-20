use warnings;
srand;

print "Welcome to hangman!\n";

#Opens the file for reading
my $dictionary = "testDictionary.txt";
open(my $fd, "<", $dictionary)
	or die "Can't open ", $dictionary;
my $word = "Default Value";
my $randomLine = int(rand(10));
print "Random line is: ", $randomLine, "\n";
my $counter = 0;
while($word eq "Default Value"){
	my $randomLine = int(rand(10));
	while (<$fd> and ($word eq "Default Value")){

		if ($counter == $randomLine) {
			$word = <$fd>;
		}
		$counter++;
	}
	$randomLine = int(rand(10));
}
chomp $word;
print "secret word is: ", $word, "\n";
