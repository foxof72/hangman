use Twitter::API;
require keys;

#Initalizing the bot
#THESE MUST BE FILLED IN PRIOR TO RUNTIME AND KEPT MEGA SECRET
my $client = Twitter::API->new_with_traits(
        traits              => 'Enchilada',
        consumer_key        => $keys::consumer_key,
        consumer_secret     => $keys::consumer_secret,
        access_token        => $keys::access_token,
        access_token_secret => $keys::access_token_secret,
    );

my $me   = $client->verify_credentials;
my $user = $client->show_user('twitter');
