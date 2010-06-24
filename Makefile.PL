use inc::Module::Install;
name 'Qudo-Hook-ForceQuitJob';
all_from 'lib/Qudo/Hook/ForceQuitJob.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
