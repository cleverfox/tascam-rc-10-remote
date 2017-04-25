#!/usr/local/bin/perl
use strict;
use v5.10;
use IO::Handle qw( );  # For autoflush
use Term::ANSIColor;
use Device::SerialPort;
#use Text::Iconv;

my $debug=0;
my $port="/dev/cuaU0";
my $com = new Device::SerialPort ($port, 1);
die "Can't open port" unless $com;

$com->user_msg("ON");
$com->databits(8);
$com->baudrate(9600);
$com->parity("even");
$com->stopbits(1);
$com->handshake("none");

$| = 1;
while(1){
    my $got;
    print "(Q)uit (1)Prev (2)Next (3)Stop (4)Play (5)Rec (6)M (7)F1 (8)F2 (9)+ (10)- ";
    $got = getone();
    my $cmd=0;
    if($got eq 'q'){
        last;
    }elsif($got eq '1'){
        $cmd=15;
        say('prev');
    }elsif($got eq '2'){
        $cmd=14;
        say('next');
    }elsif($got eq '3'){
        $cmd=8;
        say('pause/stop');
    }elsif($got eq '4'){
        $cmd=9;
        say('play/step back');
    }elsif($got eq '5'){
        $cmd=11;
        say('rec');
    }elsif($got eq '6'){
        $cmd=24;
        say('M');
    }elsif($got eq '7'){
        $cmd=28;
        say('F1/INT 1/2');
    }elsif($got eq '8'){
        $cmd=29;
        say('F2/EXT 3/4');
    }elsif($got eq '9'){
        $cmd=30;
        say('F3/+');
    }elsif($got eq '0'){
        $cmd=31;
        say('F4/-');
    } 
    say($cmd);
    if($cmd){
        $com->write(sprintf("%c",128+$cmd));
        select(undef, undef, undef, 0.5);
        $com->write(sprintf("%c",$cmd));
    }
}

$com->close || die "failed to close";
undef $com;


exit;

BEGIN {
use POSIX qw(:termios_h);

my ($term, $oterm, $echo, $noecho, $fd_stdin);

$fd_stdin = fileno(STDIN);

$term     = POSIX::Termios->new();
$term->getattr($fd_stdin);
$oterm     = $term->getlflag();

$echo     = ECHO | ECHOK | ICANON;
$noecho   = $oterm & ~$echo;

sub cbreak {
    $term->setlflag($noecho);
    $term->setcc(VTIME, 1);
    $term->setattr($fd_stdin, TCSANOW);
    }

sub cooked {
    $term->setlflag($oterm);
    $term->setcc(VTIME, 0);
    $term->setattr($fd_stdin, TCSANOW);
    }

sub getone {
    my $key = '';
    cbreak();
    sysread(STDIN, $key, 1);
    cooked();
    return $key;
    }

}

END { cooked() }
