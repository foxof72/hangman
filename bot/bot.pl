#!/usr/bin/env perl

# link for building:
# https://elements.heroku.com/buildpacks/judofyr/perloku
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
my $idFile = 'ids.txt';
open(my $idFH, '+<', $idFile)
    or die "cannot open file $idFile"; # id file
#my $oldestScreen = $senderArray[$outerI];

#the main body of the bot, runs forever cause the bot never goes down
my $datestring = localtime();
print $fh "Log opened at $datestring\n\n";
print "Bot is live! Check $logName for log.\n";
my $oldestID = -1;
while(1){
    # gets DMs
    print "Top of the loop!\n";
    my @textArray = ();
    my @idArray = ();
    my @senderArray = ();
    my $i = 0;
    while (my $row = <$idFH>) {
        chomp $row;
        # print "id: $row\n";
        $oldestID = $row;
    }
    seek $idFH, 0, 0; # go back to the start of the file
    print $fh "ID: $oldestID\n";
    my $dms = $bot->mentions({since_id => $oldestID});
    my $userName = "themetricbot";
    for my $status ( @$dms ) {
        my $textToCheck = lc("$status->{text}");
        chomp $textToCheck;
        # print "tweet text: $textToCheck\n";
        #  index($textToCheck, $userName);
        if ((length($textToCheck) == 13) and (index($textToCheck, $userName) == 1))  {
            $textArray[$i] = "$status->{text}";
            $idArray[$i] = "$status->{id}";
            print $fh "Added id with $idArray[$i] to array\n";
            $senderArray[$i] = "$status->{user}{screen_name}";
            $i++;
        } else {
            if(index($textToCheck, " ") != -1){
                my @tweetDecider = split ' ',   $textToCheck;
                # print "array: @tweetDecider\n";
                my $lengthOfDecider = scalar(@tweetDecider);
                # print "$lengthOfDecider\n";
                # print $tweetDecider[$lengthOfDecider-1], "\n";
                #if (((length($textToCheck) == 13) and (index($textToCheck, $userName) != -1))) 
                if(index($tweetDecider[$lengthOfDecider-1], $userName) != -1){
                    $textArray[$i] = "$status->{text}";
                    $idArray[$i] = "$status->{id}";
                    print $fh "Added id with $idArray[$i] to array\n";
                    $senderArray[$i] = "$status->{user}{screen_name}";
                    $i++;
                }
            }
        }
        my $line = <$idFH>;
        $line = "$status->{id}";
        print "new id in file is $line";
        seek $idFH, 0, 0; # go back to the start of the file
        printf $idFH $line;
    }
    # print "ids: ", @idArray, "\n";
    # print "senderArray: ", @senderArray, "\n";
    my $idCounter = 0;
    my $previousTweet;
    if($i != 0){
        $previousTweet = 0;
        while($i != $idCounter){
            # gets words for wordcloud
            # print "id is $idCounter \n";
            # print "i is $i \n";
            #print "oldestID is: ", $oldestID, "\n";
            #print "idArray is: ", $idArray[$idCounter], "\n";
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
            my @puncation = ("@", "don't", ".", "/", "...", "{", "}", "(", ")", "!", "?", ",", "\"", "\'s", "..", "....", ".", ":", "-", " ", "\n");
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
                if((exists($stopWords{lc($_)})) or ((index($_, "https:/tco")) != -1) or ($_ eq "don't")) {
                    next;  # if its a stop word, don't add it 
                }
            	$cloud{$_} = $counter;
            }

            #populate the value field with how often the word occurs
            foreach (@words){ # incremente the hash properly
                if((exists($cloud{lc($_)})) and ($cloud{lc($_)} ne "don't")) {
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
            print "tweeting...\n";
            $oldestID = $idArray[$idCounter];
            my $line = <$idFH>;
            $line = $idArray[$idCounter];
            print "new id in file is $line";
            seek $idFH, 0, 0; # go back to the start of the file
            printf $idFH $line;
            $idCounter++;
        }
    }
    $datestring = localtime();
    print "No new tweets at $datestring, sleeping for 11 seconds\n\n";
    sleep(11);
}
close $fh;
