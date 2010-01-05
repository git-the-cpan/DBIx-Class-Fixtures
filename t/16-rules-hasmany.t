#!perl

use DBIx::Class::Fixtures;
use Test::More tests => 11;
use lib qw(t/lib);
use DBICTest;
use Path::Class;
use Data::Dumper;

# set up and populate schema
ok(my $schema = DBICTest->init_schema(), 'got schema');

my $config_dir = 't/var/configs';

# do dump
ok(my $fixtures = DBIx::Class::Fixtures->new({ config_dir => $config_dir, debug => 0 }), 'object created with correct config dir');
ok($fixtures->dump({ config => 'rules2.json', schema => $schema, directory => 't/var/fixtures' }), 'quantity dump executed okay');

# check dump is okay
foreach my $test (
  [ 'artist', 1, 'Artist', 'artistid' ],
  [ 'cd', 2, 'CD', 'cdid' ],
) {
  my ($dirname, $count, $moniker, $id) = @$test;
  my $dir = dir("t/var/fixtures/$dirname");
  my @children = $dir->children;
  is(scalar(@children), $count, "right number of $dirname fixtures created");

  foreach my $fix_file (@children) {
    my $HASH1; eval($fix_file->slurp());
    is(ref $HASH1, 'HASH', 'fixture evals into hash');
    my $obj = $schema->resultset($moniker)->find($HASH1->{$id});
    is_deeply({$obj->get_columns}, $HASH1, "dumped fixture is equivalent to $dirname row");
  }
}

