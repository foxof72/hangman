use Twitter::API;


#Initalizing the bot
#THESE MUST BE FILLED IN PRIOR TO RUNTIME AND KEPT MEGA SECRET
my $client = Twitter::API->new_with_traits(
        traits              => 'Enchilada',
        consumer_key        => $YOUR_CONSUMER_KEY,
        consumer_secret     => $YOUR_CONSUMER_SECRET,
        access_token        => $YOUR_ACCESS_TOKEN,
        access_token_secret => $YOUR_ACCESS_TOKEN_SECRET,
    );

my $me   = $client->verify_credentials;
my $user = $client->show_user('twitter');
