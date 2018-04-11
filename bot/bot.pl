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

my $logName = 'log.txt';
open(my $fh, '>', $logName)
    or die "cannot open file $logName"; # log file
select $fh; $| = 1; select STDOUT;
# gets DMs
#my @textArray = ();
#my @idArray = ();
#my @senderArray = ();
#my $outerI = 0;
#my $dms = $bot->mentions();
#for my $status ( @$dms ) {
#    $idArray[$outerI] = "$status->{id}";
#    $senderArray[$outerI] = "$status->{user}{screen_name}";
#}

my $oldestID = -1; # will never be this, ensuring it will act on the first tweet
#my $oldestScreen = $senderArray[$outerI];

#the main body of the bot, runs forever cause the bot never goes down
my $datestring = localtime();
print $fh "Log opened at $datestring\n\n";
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
        $senderArray[$i] = "$status->{user}{screen_name}";
        $i++;
    }
    # print "ids: ", @idArray, "\n";
    # print "senderArray: ", @senderArray, "\n";
    my $idCounter = 0;
    if($i != 0){
        while($oldestID != $idArray[$idCounter]){
            # gets words for wordcloud
            my $text;
            my @statusText = ();
            my $j = 0;
            my $tweets = $bot->user_timeline({screen_name => $senderArray[$idCounter], count => 100, exclude_replies => 1, include_rts => 1});
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
            my $tweetText = '@';
            $tweetText .= $senderArray[$idCounter];
            $tweetText .=  " 5 most used words are: \n";
            my $printCount = 0;
            foreach my $name (sort { $cloud{$b} <=> $cloud{$a} } keys %cloud) { #sort the hash
                if($printCount == 5){
                    last;
                }
                $tweetText .= $printCount + 1; 
                $tweetText .= ". "; #the number and a dot for looking nice
                $tweetText .= $name;  
                $tweetText .= " ";
                $tweetText .= $cloud{$name}; #the word and its uses
                $tweetText .= "\n"; #new line at the end
                # printf "%-8s %s\n", $name, $cloud{$name};
                $printCount++;
            }
            # print "The tweet text: ", $tweetText, "\n";
            $bot->update($tweetText, {in_reply_to_status_id => $idArray[$idCounter]});
            $datestring = localtime();
            print $fh "Tweeted $tweetText at $datestring\n\n";
            $oldestID = $idArray[$idCounter];
        }
    }
    $datestring = localtime();
    print $fh "No new tweets at $datestring, sleeping for 11 seconds\n\n";
    sleep(11);
}
close $fh;
