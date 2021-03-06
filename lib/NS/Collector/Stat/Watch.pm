package NS::Collector::Stat::Watch;

use strict;
use warnings;
use Carp;
use POSIX;

use NS::Collector::Util;

sub co
{
    my ( $this, @watch, @stat, %watch ) = @_;

    push @stat, [ 'WATCH', 'current', 'type' ];

    map{ $watch{$1} = 1 if $_ =~ /^\{WATCH\}\{([^}]+)\}\{\w+\}/ }@watch;

    for my $watch ( keys %watch )
    {
        my @data = ( $watch );

        if( -l $watch )
        {
            push @data, readlink $watch, 'link';
        }
        elsif( -f $watch )
        {
            my $cont = NS::Collector::Util::qx( "cat '$watch'" ); chomp $cont;
            push @data, $cont, 'cont';
        }
        else
        {
            push @data, '', 'unkown';
        }

        push @stat, \@data;
    }

    return \@stat;
}

1;
