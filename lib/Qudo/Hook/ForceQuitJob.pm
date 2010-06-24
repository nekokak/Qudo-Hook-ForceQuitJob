package Qudo::Hook::ForceQuitJob;
use strict;
use warnings;
use base 'Qudo::Hook';

our $VERSION = '0.01';

sub load {
    my ($class, $klass) = @_;

    $SIG{ALRM} = sub {
        die 'force quit job...';
    };

    $klass->hooks->{pre_work}->{'force_quit_job'} = sub {
        my $job = shift;
        my $grab_for = $job->funcname->grab_for;
        return unless $grab_for;
        alarm $grab_for;
    };

    $klass->hooks->{post_work}->{'force_quit_job'} = sub {
        my $job = shift;
        alarm 0;
    };
}

sub unload {
    my ($class, $klass) = @_;

    $SIG{ALRM} = sub {};
    delete $klass->hooks->{pre_work}->{'force_quit_job'};
    delete $klass->hooks->{post_work}->{'force_quit_job'};
}

1;
__END__

=head1 NAME

Qudo::Hook::ForceQuitJob - abort.

=head1 SYNOPSIS

    $manager->register_hooks(qw/Qudo::Hook::ForceQuitJob/);

=head1 DESCRIPTION

Qudo::Hook::ForceQuitJob is

=head1 AUTHOR

Atsushi Kobayashi E<lt>nekokak _at_ gmail _dot_ comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
