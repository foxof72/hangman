use Twitter::API;
use keys;
use strict;
use warnings;

#Initalizing the bot
#THESE MUST BE FILLED IN PRIOR TO RUNTIME AND KEPT MEGA SECRET
my $bot = Twitter::API->new_with_traits(
        traits              => 'Enchilada',
        consumer_key        => $keys::consumer_key,
        consumer_secret     => $keys::consumer_secret,
        access_token        => $keys::access_token,
        access_token_secret => $keys::access_token_secret,
    );

# gets DMs
my @textArray = ();
my @idArray = ();
my @senderArray = ();
my $outerI = 0;
my $dms = $bot->mentions();
for my $status ( @$dms ) {
    $idArray[$outerI] = "$status->{id}";
    $senderArray[$outerI] = "$status->{screen_name}";
}

my $oldestID = $idArray[$outerI];
my $oldestScreen = $senderArray[$outerI];
#the main body of the bot, runs forever cause the bot never goes down
while(1){
    # gets DMs
    my @textArray = ();
    my @idArray = ();
    my @senderArray = ();
    my $i = 0;
    my $dms = $bot->mentions();
    for my $status ( @$dms ) {
        $textArray[$i] = "$status->{text}";
        $idArray[$i] = "$status->{id}";
        $senderArray[$i] = "$status->{user->screen_name}";
        $i++;
    }
    print "ids: ", @idArray, "\n";
    # print "ids: ", $idArray[1], "\n";
    print "senderArray: ", @senderArray, "\n";
    last;
    if (($oldestID != $idArray[0]) and ($oldestScreen eq $senderArray[0])) {
        # gets words for wordcloud
        my $text;
        my @statusText = ();
        my $j = 0;
        my $tweets = $bot->user_timeline({screen_name => "notjohnwill", count => 100, exclude_replies => 1, include_rts => 1});
        for my $tweetOut ( @$tweets ) {
            $text = "$tweetOut->{text}\n";
            $statusText[$j] = $text;
            $j++;
        }

        #"flatten" all the tweets into one string
        my $stringTotal = "";
        foreach (@statusText) {  
            chomp $_;
            $stringTotal .= $_
        }

        #process status text by removing puncation and similar things
        my @puncation = (".", "/", "...", "{", "}", "(", ")", "!", "?", ",", "\"", "\'s", "..", "....", ".", ":");
        my @words = split ' ',   $stringTotal;
        for (my $var = 0; $var < scalar(@words); $var++) {
            my $current = $words[$var];
            for (my $j = 0; $j < scalar(@puncation); $j++) {
                if(index($current, $puncation[$j]) != -1){
                    substr($current, index( $current, $puncation[$j] ), 1, "");
                }
            }
            $words[$var] = lc($current);
        }

        # assemble the hash of the words
        # Key: the word
        # Value: how often it appears
        my $wordsFile = "stopWords.txt";
        open(my $fd, "<", $wordsFile)
            or die "Can't open ", $wordsFile;
        my %stopWords;
        while(my $line = <$fd>){
            chomp $line;
            $stopWords{$line} = 0;
        }
        my %cloud; # hash of words to be used
        my $counter = 0; # how often is a word found
        foreach (@words){  # add every word to the hash, except noted stop words
            if((exists($stopWords{lc($_)})) or ((index($_, "https:/tco")) != -1)) {
                next;  # if its a stop word, don't add it 
            }
        	$cloud{$_} = $counter;
        }

        #populate the value field with how often the word occurs
        foreach (@words){ # incremente the hash properly
            if(exists($cloud{lc($_)})) {
                $cloud{$_}++;
            }
        }

        #sort the hash and print the top 5 words
        my $printCount = 0;
        foreach my $name (sort { $cloud{$b} <=> $cloud{$a} } keys %cloud) { #sort the hash
            if($printCount == 5){
                last;
            }
            printf "%-8s %s\n", $name, $cloud{$name};
            $printCount++;
        }
    }
}
