use strict;
use warnings;
use Test::More;
use Test::Requires 'HTTP::Request';

{
    package MyDispatcher;
    use Router::Simple::Declare::Class;

    connect '/' => {controller => 'Root', action => 'show'}, {method => 'GET'};
    connect '/blog/{year}/{month}', {controller => 'Blog', action => 'monthly'}, {method => 'GET'};
    connect '/blog/{year:\d{1,4}}/{month:\d{2}}/{day:\d\d}', {controller => 'Blog', action => 'daily'}, {method => 'GET'};
    connect '/comment', {controller => 'Comment', 'action' => 'create'}, {method => 'POST'};

}

is_deeply(
    MyDispatcher->match( HTTP::Request->new( GET => 'http://localhost/' ) ) || undef,
    {
        controller => 'Root',
        action     => 'show',
        args       => {},
    }
);
is_deeply(
    MyDispatcher->match( HTTP::Request->new( GET => 'http://localhost/blog/2010/03' ) ) || undef,
    {
        controller => 'Blog',
        action     => 'monthly',
        args       => {year => 2010, month => '03'},
    }
);
is_deeply(
    MyDispatcher->match( HTTP::Request->new( GET => 'http://localhost/blog/2010/03/04' ) ) || undef,
    {
        controller => 'Blog',
        action     => 'daily',
        args       => {year => 2010, month => '03', day => '04'},
    },
    'daily'
);
is_deeply(
    MyDispatcher->match( HTTP::Request->new( POST => 'http://localhost/blog/2010/03' ) ) || undef,
    undef
);
is_deeply(
    MyDispatcher->match( HTTP::Request->new( POST => 'http://localhost/comment' ) ) || undef,
    {
        controller => 'Comment',
        action     => 'create',
        args       => {},
    }
);

done_testing;
