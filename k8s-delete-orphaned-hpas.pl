#!/usr/bin/env perl

use JSON;

$dryrun = $ARGV[0] =~ /dry/;

$|=1;
$json = JSON->new;

$j = `kubectl get hpa --all-namespaces -o json`;
$hpas = $json->decode($j);
foreach $hpa (@{$hpas->{items}}) {
    next if($hpa->{spec}->{scaleTargetRef}->{kind} ne 'Deployment');
    $name = $hpa->{metadata}->{name};
    $namespace = $hpa->{metadata}->{namespace};
    $deploy = $hpa->{spec}->{scaleTargetRef}->{name};
    $get = `kubectl -n $namespace get deploy $deploy 2>&1`;
    if($get =~ /not found/) {
        print "kubectl -n $namespace delete hpa $name\n";
        print `kubectl -n $namespace delete hpa $name` unless($dryrun);
    }
}
