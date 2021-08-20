#!/usr/bin/perl

use Expect;

#$|++; # no bufferin'

my $exp = Expect->new();
$curPasswd = "bac234qwe.1";
$newPasswd = "newPasswd.1";
$user      = "user1";
$server    = "localhost";

#$exp->log_file( '/tmp/expecthist' );
#$exp->log_stdout( 0 );
#$exp->raw_pty( 1 );

$exp->spawn( 'ssh -t -q -o StrictHostKeychecking=no "user1@localhost" "passwd"' ) or die qq{Can't start a shell!};

$exp->expect( 5 =>
   [ qr/.*\@.*password:\s+/i          => sub { 
                                                my $self = shift;
                                                $self->send("$curPasswd\n");
                                                exp_continue; 
                                             }],
   [ qr/.*UNIX password:\s+/i         => sub { 
                                                my $self = shift;
                                                $self->send("$curPasswd\n");
                                                exp_continue;
                                             }], 
   [ qr/New password:\s+/i            => sub { 
                                                my $self = shift;
                                                $self->send("$newPasswd\n");
                                                exp_continue; 
                                             }],   
   [ qr/Retype new password:\s+/i     => sub {
                                                my $self = shift;
                                                $self->send("$newPasswd\n");
                                                $exp->do_soft_close(); 
                                                exp_continue; 
                                             }],

   [ timeout                          => sub {}    ],
   [ eof                              => sub {}    ],
)
