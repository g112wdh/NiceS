package NS::Watch::Client;
use strict;
use warnings;

use Carp;

use IO::Socket;
use IO::Select;
use Time::HiRes qw/time/;

use constant TIMEOUT => 30;


sub new
{
    my ( $class, %this ) = @_;

    confess "undef server.\n" unless $this{server};
   
    $this{sock} = my $sock = IO::Socket::INET->new(
        Blocking => 0, Timeout => TIMEOUT,
        Proto => 'tcp', Type => SOCK_STREAM,
        PeerAddr => $this{server},
    );

    die "socket:[addr:$this{server}] $!\n" unless $sock;
    return bless \%this, ref $class || $class;
}

sub run
{
    my $this = shift;
    my $sock = $this->{sock};

    my $select = IO::Select->new();
    $select->add( $sock );

    while( <> )
    {
        next unless my $input = $_;
        chomp $input;
          
        next unless $input;
        $sock->send( $input );

        map{
            my ( $fh ) = $select->can_read( 0.1 );
            if( $fh && ( my $mesg = <$fh> ) )
            {
                chomp $mesg;
                print "$mesg\n";
            }
        }0 .. 9;
    }
}

1;
