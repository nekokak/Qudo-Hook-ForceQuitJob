use Qudo::Test;
use Test::More;
use Test::SharedFork;

run_tests(2, sub {
    my $driver = shift;
    my $master = test_master(
        driver_class => $driver,
    );

    my $manager = $master->manager;
    $manager->can_do('Worker::Test1');
    $manager->can_do('Worker::Test2');
    $manager->register_hooks(qw/Qudo::Hook::ForceQuitJob/);

    $manager->enqueue("Worker::Test1", {});

    $manager->enqueue("Worker::Test2", {});

    if ( fork ) {
        $manager->work_once;
        wait;
    } else {
        # child
        for my $dsn ($manager->shuffled_databases) {
            my $db = $manager->driver_for($dsn);
            $db->reconnect;
        }
        $manager->work_once;
    }

    my $exception = $master->exception_list;
    my ($db, $rows) = %$exception;
    like $rows->[0]->{message}, qr/^force quit job/;
    is scalar(@$rows), 1;

    teardown_dbs;
});

package Worker::Test1;
use base 'Qudo::Worker';

sub grab_for { 3 }
sub work {
    my ($class, $job) = @_;
    sleep 5;
    $job->completed;
}

package Worker::Test2;
use base 'Qudo::Worker';

sub grab_for { 10 }
sub work {
    my ($class, $job) = @_;
    sleep 5;
    $job->completed;
}
