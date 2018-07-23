#!/usr/bin/env perl
use 5.018;

my $fname = $ARGV[0];
my $BLOCK_SIZE = 0x4400;
my $aw = 0x20;
my $ssize = 0x80;
my ($cnt, $rs, $buf);

open(F,"<$fname") or die("Unable to open file $fname, $!");
binmode(F); read(F,$buf,$BLOCK_SIZE);
my @buf = unpack "C*", $buf;

while(1){
	$rs = ($cnt * $ssize)+$aw+0x400;
	my @a = @buf[$rs .. $rs+7]; my @b = @buf[$rs+8 .. $rs+15];
	push @a, @b;
	my @ret = ltob(@a);
	my $size = ($ret[0]-$ret[1]+1);
	last if($size <= 1);
	printf("%d sector Address : 0x%x, size : 0x%x\n",$cnt+1,$ret[1],$size);
	$cnt++;
}
say "end parsing";

sub ltob(){
	my $end = sprintf("%02x%02x%02x%02x%02x%02x%02x%02x",$_[-1],$_[-2],$_[-3],$_[-4],$_[-5],$_[-6],$_[-7],$_[-8]);
	my $start = sprintf("%02x%02x%02x%02x%02x%02x%02x%02x",$_[-9],$_[-10],$_[-11],$_[-12],$_[-13],$_[-14],$_[-15],$_[-16]);
	my @re = (hex($end),hex($start));
	return @re;
}
