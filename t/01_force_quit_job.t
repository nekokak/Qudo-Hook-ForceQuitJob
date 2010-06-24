use Qudo::Test;
use Test::More;

run_tests(1, sub {
    my $driver = shift;
    my $master = test_master(
        driver_class => $driver,
    );

    my $manager = $master->manager;
    $manager->can_do('Worker::Test');
    $manager->register_hooks(qw/Qudo::Hook::ForceQuitJob/);

    $manager->enqueue("Worker::Test", {});
    $manager->work_once;

    my $exception = $master->exception_list;
    my ($db, $rows) = %$exception;
    like $rows->[0]->{message}, qr/^force quit job/;

    teardown_dbs;
});

package Worker::Test;
use base 'Qudo::Worker';

sub grab_for { 3 }
sub work {
    my ($class, $job) = @_;
    sleep 5;
}
