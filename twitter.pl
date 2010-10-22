#!/usr/bin/perl
use strict;
use warnings;

use AnyEvent::Twitter::Stream;
use AnyEvent::Handle;
use AnyEvent::Socket;
use Encode 'encode_utf8';
use Config::Pit;

my $conf = pit_get('twitter.com', require => {
    consumer_key    => 'consumer_key',
    consumer_secret => 'consumer_secret',
    token           => 'token',
    token_secret    => 'token_secret',
});

my $cv = AE::cv;

tcp_connect '127.0.0.1', 25250, sub {
    my ($fh) = @_ or die;

    my $hdl; $hdl = AnyEvent::Handle->new(fh => $fh);
    my $listener; $listener = AnyEvent::Twitter::Stream->new(
        %$conf,
        method => 'userstream',
        on_tweet => sub {
            my $tweet = shift;
            scalar $listener;
            return unless ($tweet->{text} && $tweet->{user}{screen_name});

            $tweet->{text} =~ s/\n/ /g;
            $hdl->push_write(encode_utf8 "\@$tweet->{user}{screen_name}: $tweet->{text}\n");
        },
        on_error => sub { $cv->send },
    );
};
$cv->recv;
