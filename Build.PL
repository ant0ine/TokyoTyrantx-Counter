use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'TokyoTyrantx::Counter',
    license             => 'perl',
    dist_author         => 'Antoine Imbert <antoine.imbert@gmail.com>',
    dist_version_from   => 'lib/TokyoTyrantx/Counter.pm',
    dist_abstract       => 'A very simple counter mechanism based on Tokyo Tyrant', 
    build_requires => {
        'Test::More' => 0,
        'TokyoTyrant' => 0,
        'TokyoTyrantx::Instance' => 0,
    },
    add_to_cleanup      => [ 'TokyoTyrantx-Counter-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
