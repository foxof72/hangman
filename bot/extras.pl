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