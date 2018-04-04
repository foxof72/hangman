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
my $temp;
my @output = ();
my $i = 0;
my $dms = $bot->direct_messages();
for my $status ( @$dms ) {
    $temp = "$status->{text}\n";
    $output[$i] = $temp;
}

# print @output;

# gets words for wordcloud
my $text;
my @statusText = ();
my $j = 0;
my $tweets = $bot->user_timeline({screen_name => "DailyKerouac", count => 5, exclude_replies => 1, include_rts => 0});
for my $tweetOut ( @$tweets ) {
    $text = "$tweetOut->{text}\n";
    $statusText[$j] = $text;
    $j++;
}

#"flatten" all the tweets into one string
my $stringTotal = "";
foreach (@statusText) {
  $stringTotal .= $_
}
# print "string: ", $stringTotal;

#process status text by removing puncation and similar things
my @puncation = (".", "/", "...", "{", "}", "(", ")", "!", "?", ",", "\"", "\'s");
my @words = split ' ',   $stringTotal;
for (my $var = 0; $var < scalar(@words); $var++) {
    my $current = $words[$var];
    print "before current: ", $current, "\n";
    for (my $j = 0; $j < scalar(@puncation); $j++) {
        if(index($current, $puncation[$j]) != 1){
            substr($current, index( $current, $puncation[$j] ), 1, "");
            # $current =~ s/$puncation[$j]//;
        }
    }
    print "after current: ", $current, "\n";
    $words[$var] = $current;
}

# assemble the hash of the words
# Key: the word
# Value: how often it appears
my %cloud;
my $counter = 0;
foreach (@words){  # add every word to the hash
	$cloud{$_} = $counter;
}
foreach (@words){ # incremente the hash properly
	$cloud{$_}++;
}
foreach my $name (sort { $cloud{$b} <=> $cloud{$a} } keys %cloud) { #sort the hash
    # printf "%-8s %s\n", $name, $cloud{$name};
}
